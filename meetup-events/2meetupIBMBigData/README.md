#II Meetup - IBM Open Platform with Apache Hadoop - July, 17, 2015 - Madrid, Spain

Location of the event: IBM Client Center Madrid - Calle Corazón de María, 44, Madrid.
Time: 9:00 to 13:30<BR>
Hashtag: #IBMHadoop<BR>

Slides:
All the slides will be in the Meetup website.

VM (Virtual Machine)
user: biadmin
password: biadmin

In the event they gave us a VM with the IBM Big Data Software.

IBM Open Platform with Apache Hadoop
http://www.meetup.com/pt/Big-Data-Developers-in-Madrid/events/223125453/

user: biadmin
password: biadmin

Script to start the IBM Big Data
/home/biadmin/adm/start.sh

Services 

Stop
stop-all.sh

Start
start-all.sh


Agenda

9:00-9:15 - Registration
9:15-9:30 - Introduction
9:30-10:00 - Apache Spark
10:00 - 10:30 - Café
10:30 - 11:00 - IBM Hadoop Distribution: BigInsights
11:00-11:30 - Demo de Minería de Texto con Hadoop Text Analytics
11:30 - 12:00 - Ejecutando Lenguaje R en Hadoop

Speaker 1 - Introduction - Who??

IBM Analytics is investing a lot on Analytics in areas like: congnitive analytics, predictive analytics, business intelligence, etc.

IBM is part of Open Data Platform and is supporting in a lot of ways the Big Data Ecosystem.

Open Data Platform (ODP)
An ecosystem to keep Hadoop Open and Standard.
IBM is a partner of this group of company as others like: GE, HortonWorks, Infosys, Pivotal, Telstra, SAS, Teradata, EMC, etc.
http://opendataplataform.org 

Cloudera is not part of the Open Data Platform (ODP).

Speaker 2: - Luis Reina - Introduction

Luis talked about the agenda for the morning and it is:

Agenda

9:00-9:15 - Registration
9:15-9:30 - Introduction
9:30-10:00 - Apache Spark
10:00 - 10:30 - Café
10:30 - 11:00 - IBM Hadoop Distribution: BigInsights
11:00-11:30 - Demo de Minería de Texto con Hadoop Text Analytics
11:30 - 12:00 - Ejecutando Lenguaje R en Hadoop

Speaker 3 - Arancha Ocaña - Apache Spark

Spark is a evolution of Hadoop.

Spark is very very fast, faster than MapReduce.

Pig, hive are moving to Spark, because it is the future and IBM is “apostando” in it.

In the next 10 years everybody will go to Spark.

The Open Source community is turning to Spark and leaving Map Reduce.

"MapReduce is slow.” said by at II Meetup - IBM Open Platform with Apache Hadoop

Apache Spark is open source. Not a product. It is an in-memory compute engine that works with data. Not a data store.

Databricks founded by the creators of Spark from UC Berkeley’s AMPLab

RDD = Resilient Distributed Dataset

- Transform
- Actions

Code example:
```
------------------------------------------------------------------
// Creating the RDD
val logFile = sc.textFile(“hdfs://…”)

// Transformations
val errors = logFile.filter(_.startsWith(“ERROR”))
val messages = errors.map(_.split(“\t”)).map(r=> r(1))

// Caching
messages.cache()

//Actions
messages.filter(_.contains(“mysql”)).count()
messages.filter(_.contains(“php”)).count()
```

------------------------------------------------------------------

Spark is written in Scala by you can also code in Python, Scala and Java.

There are more things written in Scala in terms of libraries, less in Python but they are working to have all the same libraries and functionalities in Python.

Libraries:
Spark SQL - To run SQL in Spark
Spark Streaming -  Real Time Analytics
GraphX - Specializade in Graphs (Grafos)
MLlib = Machining Learning 
SparkR = Spark + R 

You can use Spark as stand-alone or as a cluster.

In the Hadoop Ecosystem Spark will be a another engine like Map Reduce v2. It is a processing Framework.

You can use two options of Processing Framework:
Map Reduce v2
Map Reduce v2
Spark = Better for Real Time


IBM is very commited with Spark. They gave SystemML, they created Spark Technology Center, Founding Member of AMPLab, they want to educate 1 Million Data Scientists and Data Engineers.

SystemML
SystemML unifies the fractured machine learning environments
Gives the core Spark ecosystem a complete set of DML
Allows a data scientist 

Educate 1 Million Data Scientists and Data Engineers
- BigData University

http://bigdatauniversity.com
#IBMHadoop

Spark Techonology Center
- Inspire the use of Spark to solve business problems.
- Each dollar invested it will give you 13 dollars when you invest in analytics.


Speaker 3 - Arancha Ocaña - IBM Hadoop Distribution: BigInsights

ODP (Open Data Platform) will help all Hadoop vendors keep the same versions of the Hadoop Core.
To participate in the ODP Iniciative all vendors needs to use Hadoop Core just with Apache Parts.

Parts of ODP
Ambari
Avro
Flume
HBase
Hive
Know
Lucene
Solr
Oozie
Parquet
R
Slider
Spark
Sqoop
YARN
Zookeeper

What is Ambari?

Apache Ambari is the open source operational platform to provision, manage and monitor Hadoop clusters.

What is Avro?

What is Flume?

What is HBase?

What is Hive?


Differences between the IBM Hadoop Distribution: BigInsights Community Edition from the Enterprise Edition 
GPFS-FPO vs HDFS
Platform Symphony
Better Scheduling Capability
Spreadsheet-style analysis (BigSheets)
Geospatial capabilities in BigSheets
Big SQL
Text Analytics / Text analytics Tooling

Comments:
In my opinion using Amazon S3 will be a option for HDFS or GPFS-FPO.

Text Analytics
AQL (Annotator Query Language)
Needs a extractor in the language


Speaker 4 - Demo de Minería de Texto con Hadoop: Text Analytics - Juan Caravaca

In this section we had a demo about the IBM product called IBM Insights Text Analytics.

The product was hosted in the IBM Cloud. Their cloud is bluemix.net.

It is very easy to create a Extractor to analyze text using this product.

They already have an extractor for places.

Dictionary = You create it to find options, like Region.

The options in this Dictionary will be Madrid, Aragon, Andalucia, Catalunia, etc

After you create the “Document” to parser your text it will generates automatic the extractor in AQL.

Then you can run it in a cluster. In a real example you could run it on a cluster and it will export the result to .csv, txt, json or anything.

Artifacts = AQL Code created by the User Interface of Text Analytics

The tool is more to parser the text without having to code, more for users.

It does not have more sophisticated functions that need to be done in R.

Speaker 4 - Juan Caravaca - Ejecutando Lenguaje R en Hadoop: BigR

Talked about the BigR package.

Using this package in R you can run R in a Hadoop Cluster.

They donate to the community SystemML.

# Load BigR package
library(bigr)

K-Means = It is good to use 
Similar Clients using this Al


library(RHipe)

Last part - Hands On - Laboratorio de Big R

Time to follow a guide with the exercises and eat pizzas, jamon, tortillas, etc.


My doubts:

Q. What is the difference between BigR and SystemML?

BigR = Paquete R = La interface con IBM System ML

IBM SystemML = APIs inside the IBM BigInsights.

DML (Declarity Machine Learning Language) 

IBM SystemML

Q. What is the difference between BigR and RHadoop?

RHadoop you have to do the MapReduce in the R Code.

Using BigR you can do a normal R Code and BigR will do the MapReduce.

It is more easy to code using BigR because it will do the Big Data part.

Q. Can I use BigR and SystemML? Is it free software?

It is not free software, it is open source software with licenses to use it.

For free you can use the ODP version and you can contract optional support per 2000 euros per nodes.
It gives you Support for the product.

BigInsights Data Scientist 
BigR = Aprox. 4000 euros per nodes = perpetual license
20% Mantenimiento por año - Nuevas versiones and soporte al producto. (24x7x365)

You also can contract BigInsights Data Scientist as SaaS (Software as a Service)

BigInsights Data Scientist
You can test in a 5 nodes server, but you can not put in production.
