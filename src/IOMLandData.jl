module IOMLandData

using HTTP, CSV, DataFrames, EzXML, Dates, Plots

file = "data\\iom-land-registry.csv"

#functions to download and analyse the land transactions

"""
    getLatestLandTransactionLink()

get the latest link to the iom government land transaction open data

"""
function getLatestLandTransactionLink()
    url = "https://www.gov.im/about-the-government/government/open-data/economy/land-transactions/"
    urlstem = "https://www.gov.im"

    r = HTTP.request("GET", url)

    # read the body into a String
    status, headers, body = r.status, r.headers , String(r.body)

    doc = parsehtml(body)
    html = root(doc)
    xpath = "//a[text()='Land Transactions']"
    link = findfirst(xpath, html)
    
    urlstem*link["href"]
end

function updatetransactionsdata()
    fulllink = getLatestLandTransactionLink()
    
    download(fulllink,file)
end

function readlandtransactiondata(update=false)
    if update
        updatetransactionsdata()
    end

    lr = CSV.read(file,DataFrame)
    lr.Market_Value = parse.(Float64,replace.(coalesce.(lr.Market_Value,"0"),","=>""))
    lr.Consideration = parse.(Float64,replace.(coalesce.(lr.Consideration,"0"),","=>""))
    lr.Acquisition_Date = Date.(lr.Acquisition_Date,"d/m/Y")
    lr.Completion_Date = Date.(lr.Completion_Date,"d/m/Y")
    sort!(lr,:Acquisition_Date)
end

end # module
