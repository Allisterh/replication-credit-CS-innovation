# CS-innovation
Code for a project looking to model credit supply expansion over the business cycle.

## Getting Started
Once you clone the repo, please 
1. Create a new branch.
2. You will need to download the data file and place it in the remote repo that you just cloned.

The setup file will create the necessary directories. It will also run import and cleaning code so that
the bracnh you are working on builds from the main branch. You will have to issue a pull request when you are done
so that we can merge the developments into the project.

## Data Sources
1. USPTO data come from [here](https://www.uspto.gov/ip-policy/economic-research/research-datasets/patent-assignment-dataset).
2. I download Census BDSGEO dataset from [here](https://data.census.gov/table?t=Business%20Dynamics&g=010XX00US$0400000). This
data is aggregated from a survey of firms at the Census.
3. [Beck, Levine and Levkov](https://www.jstor.org/stable/40864982) (2010) have made their data available online. That data can be found [here](https://dataverse.nl/dataset.xhtml?persistentId=hdl:10411/15996). This is where the indicators for interstate and intrastate deregulation come from.
