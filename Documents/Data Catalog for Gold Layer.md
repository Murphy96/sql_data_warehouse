### **Data Catalog for Gold Layer** 



##### **Overview**



The Gold Layer is the business-level data representation, structured to support analytical and reporting uses cases. It consists of dimension tables (details around the business level objects they represent, i.e. Customers \& Products) and fact tables (an updated record of transactions) for specific business metrics. 





1. ###### **gold.dim\_customers**



**Purpose:** Stores customer details enriched with demographic and geographic data 



**Columns:** 



|**Column Name**|**Data Type** |**Description** |
|-|-|-|
|customer\_key|INT|Surrogate key uniquely identifying each customer record in dimension table|
|customer\_id|INT|Unique numerical identifier assigned to each customer |
|customer\_number|NVARCHAR (50)|Alphanumeric identifier assigned to each customer |
|first\_name|NVARCHAR (50)|First name of customer|
|last\_name|NVARCHAR (50)|Last name of customer|
|country|NVARCHAR (50)|Country of residence of customer|
|marital\_status|NVARCHAR (50)|Marital status of customer|
|gender|NVARCHAR (50)|Gender of customer|
|birthdate|DATE|Birthday of customer|
|create\_date|DATE|Date of creation of customer record|



###### **2. gold.dim\_products**



**Purpose:** Stores product details enriched with categorical information 



**Columns:**



|**Column Name**|**Data Type**|**Description**|
|-|-|-|
|product\_key|||
|product\_id|||
|product\_number|||
|product\_name|||
|category\_id|||
|subcategory|||
|maintenance|||
|cost|||
|product\_line|||
|start\_date|||

###### 

###### **3. gold.fact\_sales**



**Purpose:** Stores complete transaction information along with foreign keys of the dimension tables 



**Columns:**



|**Column Name**|**Data Type**|**Description**|
|-|-|-|
|customer\_key|INT|Surrogate key uniquely identifying each customer record in dimension table|
|customer\_id|INT|Unique numerical identifier assigned to each customer|
|customer\_number|NVARCHAR (50)|Alphanumeric identifier assigned to each customer|
|first\_name|NVARCHAR (50)|First name of customer|
|last\_name|NVARCHAR (50)|Last name of customer|
|country|NVARCHAR (50)|Country of residence of customer|
|marital\_status|NVARCHAR (50)|Marital status of customer|
|gender|NVARCHAR (50)|Gender of customer|
|birthdate|DATE|Birthday of customer|
|create\_date|DATE|Date of creation of customer record|





