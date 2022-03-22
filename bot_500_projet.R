setwd("C:/Users/bigje/Desktop/UdeS/Troisieme annee/Methodes en eco computationnelle/Meth_comp")
#install.packages("RSQLite")
packages<-c("RSQLite")
lapply(packages,require,character.only=TRUE)
#EXERCICES AVEC CSV EXEMPLES####
con1<-dbConnect(SQLite())
tbl_auteurs <- "
CREATE TABLE auteurs (
auteur VARCHAR(50),
statut VARCHAR(40),
institution VARCHAR(200),
ville VARCHAR(40),
pays VARCHAR(40),
PRIMARY KEY (auteur)
);"

dbSendQuery(con1, tbl_auteurs)


tbl_articles<- "
CREATE TABLE articles (
articleID VARCHAR(20) NOT NULL,
titre VARCHAR(200) NOT NULL,
journal VARCHAR(80),
annee DATE,
citations INTEGER CHECK(annee >=0),
PRIMARY KEY (articleID)
);"
dbSendQuery(con1, tbl_articles)

tbl_collaborations<-"
CREATE TABLE collaborations (
auteur1 VARCHAR(40),
auteur2 VARCHAR(40),
articleID VARCHAR(20),
PRIMARY KEY (auteur1, auteur2, articleID),
FOREIGN KEY (auteur1) REFERENCES auteurs(auteur),
FOREIGN KEY (auteur2) REFERENCES auteurs(auteur),
FOREIGN KEY (articleID) REFERENCES articles(articleID)
);"
dbSendQuery(con1, tbl_collaborations)

bd_auteurs <- read.csv("authors.csv",encoding = "UTF-8")
bd_articles <- read.csv("articles.csv",encoding = "UTF-8")
bd_collab <- read.csv("collaboration.csv",encoding = "UTF-8")

dbWriteTable(con1,  name = "auteurs", value = bd_auteurs, row.names = FALSE,overwrite=TRUE)
dbWriteTable(con1,  name = "articles", value = bd_articles, row.names = FALSE,overwrite=TRUE)
dbWriteTable(con1, name = "collaborations", value = bd_collab, row.names = FALSE,overwrite=TRUE)

dbReadTable(con1,"auteurs")
dbReadTable(con1,"articles")
dbReadTable(con1,"collaborations")

sql_requete_auteurs_uni <- "
SELECT auteur, institution
  FROM auteurs
  WHERE institution LIKE '%Universite de Sherbrooke'
;"
auteurs_uni <- dbGetQuery(con1, sql_requete_auteurs_uni)
head(auteurs_uni)

sql_requete_count_collab_aut <- "
SELECT auteur1, count(auteur2) AS coauteurs
  FROM collaborations
GROUP BY auteur1;"
count_collab_aut <- dbGetQuery(con1, sql_requete_count_collab_aut)

sql_requete_count_collab_aut2 <- "
SELECT auteur1, count(auteur2) AS nb_collaborations
  FROM (
  SELECT DISTINCT auteur1, auteur2
  FROM collaborations
  )
GROUP BY auteur1
ORDER BY nb_collaborations DESC
;"
count_collab_aut2 <- dbGetQuery(con1, sql_requete_count_collab_aut2)

sql_requete_most_aut <- "
SELECT articleID, count(DISTINCT auteur1) AS most_aut
FROM (
  SELECT DISTINCT articleID,auteur1
    FROM collaborations
    INNER JOIN articles USING (articleID)
)
GROUP BY articleID
;"
count_collab_most_aut <- dbGetQuery(con1, sql_requete_most_aut)
unique()
#####
con<-dbConnect(SQLite())
tbl_noeuds <- '
CREATE TABLE noeuds (
  nom_prenom      VARCHAR(50),
  annee_debut      DATE(4),
  session_debut   CHAR(1) ,
  programme       VARCHAR(20),
  coop            BOOLEAN(1),
  PRIMARY KEY (nom_prenom)
);'
dbSendQuery(con, tbl_noeuds)
dbListTables(con)
tbl_cours <- "
CREATE TABLE cours (
sigle     CHAR(6) NOT NULL,
credits       INTEGER(1) NOT NULL,
obligatoire     BOOLEAN(1),
laboratoire       BOOLEAN(1),
distance    BOOLEAN(1),
groupes   BOOLEAN CHECK(distance == 0),
libre     BOOLEAN(1),
PRIMARY KEY (sigle)
);"
dbSendQuery(con, tbl_cours)
tbl_collaborations <- "
CREATE TABLE collaborations (
  etudiant1     VARCHAR(50),
  etudiant2     VARCHAR(50),
  cours         CHAR(6),
  date          DATE(3),
  PRIMARY KEY (etudiant1, etudiant2, cours),
  FOREIGN KEY (etudiant1) REFERENCES noeuds(nom_prenom),
  FOREIGN KEY (etudiant2) REFERENCES noeuds(nom_prenom),
  FOREIGN KEY (cours) REFERENCES cours(sigle)
);"
dbSendQuery(con, tbl_collaborations)

sql_requete_cours <- "
SELECT *
  FROM cours LIMIT 10
;"
cours <- dbGetQuery(con, sql_requete_cours)
head(cours)
sql_requete_noeuds <- "
SELECT *
  FROM noeuds LIMIT 10
;"
noeuds <- dbGetQuery(con, sql_requete_noeuds)
head(noeuds)

sql_requete_collaborations <- "
SELECT *
  FROM collaborations LIMIT 10
;"
collaborations <- dbGetQuery(con, sql_requete_collaborations)
head(collaborations)

sql_del<-'DELETE FROM noeuds;'
#sql_noeuds <- '####
#INSERT INTO noeuds (
#nom_prenom,
#annee_debut,
#session_debut,
#programme ,
#coop
#)
#VALUES ("jeremi_lepage",2019,"A","ecologie",1),("xavier_stamant",2019,"A","ecologie",1)
#;'
#dbSendQuery(con, sql_noeuds,overwrite=TRUE)
##reset noeuds####
dbSendQuery(con,sql_del)
#####read csv#####
bd_noeuds <- read.csv("attributs_noeuds.csv",header=TRUE,encoding = "UTF-8",)[,-1]
bd_cours <- read.csv("attributs_cours.csv",header=TRUE,encoding = "UTF-8",)[,-1]
bd_collaborations <- read.csv("attributs_collaborations.csv",header=TRUE,encoding = "UTF-8",)[,-1]

dbWriteTable(con,  name = "noeuds", value = bd_noeuds, row.names = FALSE,overwrite=TRUE)
dbWriteTable(con,  name = "cours", value = bd_cours, row.names = FALSE,overwrite=TRUE)
dbWriteTable(con, name = "collaborations", value = bd_collaborations, row.names = FALSE,overwrite=TRUE)

dbReadTable(con,"noeuds")
dbReadTable(con,"collaborations")
dbReadTable(con,"cours")

sql_requete_count <- "
SELECT etudiant2, count(etudiant1) AS count
  FROM collaborations
GROUP BY etudiant2;"
count_collaborations <- dbGetQuery(con, sql_requete_count)
head(count_collaborations)

sql_requete_count_year <- "
SELECT etudiant2, count(etudiant2) AS count,date
  FROM collaborations
GROUP BY etudiant2, date;"
count_collaborations_year <- dbGetQuery(con, sql_requete_count_year)

