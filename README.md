# CS-innovation
Code for a project looking to model credit supply expansion over the business cycle.

## Data-Availability
At present, the user will have to construct the data themselves. To do this, clone the repo and create a folder called data in the cloned repo. Then follow [Data Sources](#data-sources) and put all the raw datasets in ``data" folder. The code is written with relative file paths following this structure.

## Data Sources
1. I have USPTO from [here](https://www.uspto.gov/ip-policy/economic-research/research-datasets/patent-assignment-dataset). But, the data that I use are disambiguated patent data from [PatentsView](https://patentsview.org/download/data-download-tables).
3. I download Census BDSGEO dataset from [here](https://data.census.gov/table?t=Business%20Dynamics&g=010XX00US$0400000). This
data is aggregated from a survey of firms at the Census. More data from the census, including BDSGEO can be found 
[here](https://www.census.gov/data/tables/time-series/econ/bds/bds-tables.html).
3. [Beck, Levine and Levkov](https://www.jstor.org/stable/40864982) (2010) have made their data available online. That data can be found [here](https://dataverse.nl/dataset.xhtml?persistentId=hdl:10411/15996). This is where the indicators for interstate and intrastate deregulation come from.
4. Bank balance sheet data are retrieved from Legacy Call report data, collected by the Federal Reserve and hosted by Wharton's Research Data Services (WRDS).
