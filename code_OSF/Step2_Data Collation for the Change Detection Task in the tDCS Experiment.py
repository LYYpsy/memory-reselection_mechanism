# data analysis and wrangling
import os, sys
import pandas as pd 
import numpy as np 
import random as rnd # Random variable generators

# visualization
import seaborn as sns 
import matplotlib.pyplot as plt #导入package中的module

directory= r"D:\Working_Files\Files\tdcs_results\Cathode"
os.chdir(directory)
# load data
data_trans = pd.read_csv('CD_key.csv')

rows_original= data_trans.shape[0]

# excluding catch trials
shape_error = data_trans[(data_trans.targetshape)==2].index.tolist()
data_trans = data_trans.drop(shape_error)  

# del error data
mem_error = data_trans[(data_trans.memACC)==0].index.tolist()
data_trans = data_trans.drop(mem_error)

# reorganisation in ID and conditions
group = data_trans['memRT'].groupby([data_trans['Id'], data_trans['irre_change']])
outlier = []
for i,j in group:
	m = j.mean()
	sd = j.std()
	l = 0
	for k in j:
		l = l+1
		if k<(m-2.5*sd) or k>(m+2.5*sd):
			outlier.append(j.index.tolist()[l-1])
# excluding data beyond the standard deviation
data_trans = data_trans.drop(outlier)

# generating a new data file
data_trans.to_csv('CD_key_clean.csv',index=0)

# convert the cleaned CSV file to Excel
df=pd.read_csv("CD_key_clean.csv")
df.to_excel("CD_key_clean.xlsx", sheet_name="key", index=False)
os.remove("CD_key_clean.csv") 



#saves the number of rows deleted
row_noCircle=rows_original-len(shape_error)
dfData = {'rows_original':[rows_original],
    'del1_circle': [len(shape_error)],
    'del2_Acc': [len(mem_error)], 
    '%Acc':[len(mem_error)/row_noCircle*100],
    'del3_SD': [len(outlier)],
    '%SD':[len(outlier)/row_noCircle*100],
     '%all_del':[(len(mem_error)+len(outlier))/row_noCircle*100]}
df_del = pd.DataFrame(dfData)
df_del.to_excel("key_del.xlsx", sheet_name="key_del", index=False)