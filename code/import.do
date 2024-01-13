program import_data

    args USPTO PatentsView

    /*****************
    Import US Patent data. The downside to unzipping files in Stata is that I can only unzip to the current
    directory. I hope this changes in the future!
    *****************/
    if `USPTO' {
        cd $data
        unzipfile "https://bulkdata.uspto.gov/data/patent/assignment/economics/2022/dta.zip", replace
        cd $code
    }

    * Import the Patentsview data
    if `PatentsView' {
        cd $data
        unzipfile "https://s3.amazonaws.com/data.patentsview.org/download/g_patent.tsv.zip", replace
        unzipfile "https://s3.amazonaws.com/data.patentsview.org/download/g_location_disambiguated.tsv.zip", replace
        unzipfile "https://s3.amazonaws.com/data.patentsview.org/download/g_assignee_disambiguated.tsv.zip", replace
        cd $code
    }
end
