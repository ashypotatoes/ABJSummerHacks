import firebase_admin
import csv
import google.cloud
import xlrd 
from firebase_admin import credentials, firestore
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import os

os.remove("Texas COVID-19 Case Count Data by County.xlsx")
def enable_download_headless(browser,download_dir):
    browser.command_executor._commands["send_command"] = ("POST", '/session/$sessionId/chromium/send_command')
    params = {'cmd':'Page.setDownloadBehavior', 'params': {'behavior': 'allow', 'downloadPath': download_dir}}
    browser.execute("send_command", params)

chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--window-size=1920x1080")
chrome_options.add_argument("--disable-notifications")
chrome_options.add_argument('--no-sandbox')
chrome_options.add_argument('--verbose')
chrome_options.add_experimental_option("prefs", {
        "download.default_directory": "<path_to_download_default_directory>",
        "download.prompt_for_download": False,
        "download.directory_upgrade": True,
        "safebrowsing_for_trusted_sources_enabled": False,
        "safebrowsing.enabled": False
})
chrome_options.add_argument('--disable-gpu')
chrome_options.add_argument('--disable-software-rasterizer')

# PATH = "/Library/Developer/CommandLineTools/usr/bin/chromedriver"    # path to webdriver file
# driver = webdriver.Chrome(PATH)

driver2 = webdriver.Chrome(chrome_options=chrome_options, executable_path=r'/Users/justinyoo/Desktop/GitHub/ABJSummerHacks/webs/chromedriver')

download_dir = "/Users/aarishbrohi/Desktop/Apps/brandon_work/webs/"

enable_download_headless(driver2, download_dir)

driver2.get("https://www.dshs.texas.gov/coronavirus/additionaldata/")

driver2.find_element_by_xpath('//*[@id="ctl00_ContentPlaceHolder1_uxContent"]/ul[1]/li[1]/a').click()


def getCases(county):
    loc = ('/Users/aarishbrohi/Desktop/Apps/brandon_work/webs/Texas COVID-19 Case Count Data by County.xlsx')
    wb = xlrd.open_workbook(loc) 
    sheet = wb.sheet_by_index(0)
    # sheet.cell_value(0, 0)
    x = 2
    column = sheet.ncols
    dog = sheet.row_values(x)
    name = dog[0]
    cat = []
    if (str(county) == 'Texas Total'):
        county = 'Total'
    while( name != str(county) ):
        x += 1
        dog = sheet.row_values(x)
        name = dog[0]
        if x > 270:
            break
    if name == str(county): 
        for i in range(2,column):
            cat.append(dog[i])
            i += 1
    return cat


def getDates():
    loc = ('/Users/justinyoo/Desktop/GitHub/ABJSummerHacks/websTexas COVID-19 Case Count Data by County.xlsx')
    wb = xlrd.open_workbook(loc) 
    sheet = wb.sheet_by_index(0)
    x = 2
    column = sheet.ncols
    dog = sheet.row_values(x)
    name = dog[0]
    cat = []
    for i in range(2,column):
        dog[i] = dog[i].replace('\r', '')
        dog[i] = dog[i].replace('Cases', '')
        dog[i] = dog[i].replace('\n', '')
        dog[i] = dog[i].replace('*', '')
        dog[i] = dog[i].replace(' ', '')

        cat.append(dog[i])
        i += 1
    return cat



# -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cred = credentials.Certificate("./ServiceAccountKey.json")
app = firebase_admin.initialize_app(cred)
store = firestore.client()
doc_ref = store.collection(u'Counties')


options = Options()
options.headless = True
options.add_argument("--window-size=1920,1200")
driver = webdriver.Chrome(options=options, executable_path=r'/Users/aarishbrohi/Desktop/Apps/brandon_work/webs/chromedriver')
driver.get("https://www.worldometers.info/coronavirus/usa/texas/")



for i in range(1, 100):
    temp = str(i)

    countyName = driver.find_element_by_xpath('//*[@id="usa_table_countries_today"]/tbody[1]/tr['+temp+']/td[1]')
    # countyCases = driver.find_element_by_xpath('//*[@id="usa_table_countries_today"]/tbody[1]/tr['+temp+']/td[2]')
    countyDeaths = driver.find_element_by_xpath('//*[@id="usa_table_countries_today"]/tbody[1]/tr['+temp+']/td[4]')

    # cases = countyCases.text.replace(',', '')
    deaths = countyDeaths.text.replace(',', '')
    if deaths == '' :
        deaths = int(0)
    daily = []
    daily = getCases(countyName.text)
    if i == 2:
        dates = getDates()
        store.collection(u'TexasTotal').document(str("Dates")).set({u'Dates': list(dates)})
        
    if daily == []:
        continue

    if countyName.text == "Texas Total":
        #-- store.collection(u'TexasTotal').document(str(countyName.text)).update({u'Trend_Cases': firestore.ArrayUnion([int(cases)])})
        store.collection(u'TexasTotal').document(str("Texas")).set({u'Name': str(countyName.text), u'Cases': int(daily[-1]), u'Deaths': int(deaths)})
        #call bottom when adding excel sheet new and set above line to 'set'
        store.collection(u'TexasTotal').document(str(countyName.text)).set({u'Name': str(countyName.text), u'Cases': int(daily[-1]), u'Deaths': int(deaths), u'Trend_Cases': list(daily)})
        # ^^ only run once daily  

    #-- doc_ref.document(str(countyName.text)).update({u'Name': str(countyName.text), u'Cases': int(cases), u'Deaths': int(deaths)})
    #-- doc_ref.document(str(countyName.text)).update({u'Trend_Cases': firestore.ArrayUnion([int(cases)])})
    doc_ref.document(str(countyName.text)).set({u'Name': str(countyName.text), u'Cases': int(daily[-1]), u'Deaths': int(deaths), u'Trend_Cases': list(daily)})
    
    
    
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    
print("DONE")
driver.close() 
