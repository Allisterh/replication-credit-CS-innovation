set timeout1 3600    // Allow Stata up to an hour to establish a connection
set timeout2 3600    // Allow Stata up to an hour to download data
/*****************
Import US Patent data. The downside to unzipping files in Stata is that I can only unzip to the current
directory. I hope this changes in the future!
*****************/
cd $data
unzipfile "https://bulkdata.uspto.gov/data/patent/assignment/economics/2022/dta.zip", replace
cd $code
