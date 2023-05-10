import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# from SyntheticControlMethods import Synth
import SparseSC


os.chdir("/Users/lukestewart/Dropbox (MIT)/14.33/Project/Analysis/Scripts/")
scripts = os.getcwd() + "/"
input = scripts.replace("Scripts/", "Input/", 1)
output = scripts.replace("Scripts/", "Output/", 1)
source = scripts.replace("Analysis/Scripts/", "Data/Processing/Output/", 1)

full_df = pd.read_csv(source + "sc_prepped.csv")
full_df.rename({'IYEAR':'YEAR', 'SMOKE_DUM':'SMOKING RATE', 'DRINKGE5':'BINGE DRINKING OCC.'}, axis=1, inplace=True)


### SMOKING SYNTHETIC CONTROLS ###

# set up data frames, then use these to set up outcomes and covariates arrays
AR_df = full_df.loc[((full_df['STATE_CODE'] == 'AR') | (full_df['EXPANSION'] == 0))]
AR_df = AR_df.loc[ (AR_df['YEAR'] < 2021) & (AR_df['YEAR'] > 1993) & (AR_df['YEAR'] < 2021)]
LA_df = full_df.loc[((full_df['STATE_CODE'] == 'LA') | (full_df['EXPANSION'] == 0))]
LA_df = LA_df.loc[ (LA_df['YEAR'] < 2021) & (LA_df['YEAR'] > 1993) & (LA_df['YEAR'] < 2021)]
KY_df = full_df.loc[((full_df['STATE_CODE'] == 'KY') | (full_df['EXPANSION'] == 0))]
KY_df = KY_df.loc[ (KY_df['YEAR'] < 2021) & (KY_df['YEAR'] > 1993) & (KY_df['YEAR'] < 2021)]
full_sc_df = full_df.loc[((full_df['STATE_CODE'].isin(['AR', 'LA', 'KY'])) | (full_df['EXPANSION'] == 0))]
full_sc_df = full_sc_df.loc[ (full_sc_df['YEAR'] < 2021) & (full_sc_df['YEAR'] > 1993) & (full_sc_df['YEAR'] < 2021)]

AR_outcomes = np.array(AR_df[['SMOKING RATE', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='SMOKING RATE'))
LA_outcomes = np.array(LA_df[['SMOKING RATE', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='SMOKING RATE'))
KY_outcomes = np.array(KY_df[['SMOKING RATE', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='SMOKING RATE'))
full_outcomes = np.array(full_sc_df[['SMOKING RATE', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='SMOKING RATE'))


AR_covariates = np.array(AR_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))
LA_covariates = np.array(LA_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))
KY_covariates = np.array(KY_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))
full_covariates = np.array(full_sc_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))

# indicate period in which treatment begins
AR_unit_treatment_periods = np.array([np.NaN if state != 'AR' else 20 for state in AR_df['STATE_CODE'].unique()])
LA_unit_treatment_periods = np.array([np.NaN if state != 'LA' else 22 for state in LA_df['STATE_CODE'].unique()])
KY_unit_treatment_periods = np.array([np.NaN if state != 'KY' else 20 for state in KY_df['STATE_CODE'].unique()])

full_unit_treatment_periods = np.array([np.NaN for state in full_sc_df['STATE_CODE'].unique()])
full_unit_treatment_periods[0] = 20
full_unit_treatment_periods[4] = 20
full_unit_treatment_periods[5] = 22

# estimate synthetic controls
pens = [0.001 for i in range(len(AR_outcomes))]
results_AR = SparseSC.estimate_effects(AR_outcomes, AR_unit_treatment_periods, model_type='retrospective', w_pens=pens)
results_LA = SparseSC.estimate_effects(LA_outcomes, LA_unit_treatment_periods, model_type='retrospective', w_pens=pens)
results_KY = SparseSC.estimate_effects(KY_outcomes, KY_unit_treatment_periods, model_type='retrospective', w_pens=pens)
results_full = SparseSC.estimate_effects(full_outcomes, full_unit_treatment_periods, model_type='retrospective', w_pens=pens)

# export results, print path estimation with p-values
sc_vs_actual = pd.DataFrame({'AR':AR_outcomes[0], 'synthetic_AR':results_AR.get_sc()[0,:], 'LA':LA_outcomes[3], 'synthetic_LA':results_LA.get_sc()[3,:], 'KY':KY_outcomes[3], 'synthetic_KY':results_KY.get_sc()[3,:]})
sc_vs_actual.to_csv(output+"sc_vs_actual_smoking.csv")

print(results_AR)
print(results_LA)
print(results_KY)
print(results_full)

### DRINKING SYNTHETIC CONTROLS ###
# copy of above, with different outcome variables, and different handling of missings
# there is only continuous data after 2000

# set up data frames, then use these to set up outcomes and covariates arrays
AR_df = full_df.loc[((full_df['STATE_CODE'] == 'AR') | (full_df['EXPANSION'] == 0))]
AR_df = AR_df.loc[ (AR_df['YEAR'] < 2021) & (AR_df['YEAR'] > 2000) & (AR_df['YEAR'] < 2021)]
LA_df = full_df.loc[((full_df['STATE_CODE'] == 'LA') | (full_df['EXPANSION'] == 0))]
LA_df = LA_df.loc[ (LA_df['YEAR'] < 2021) & (LA_df['YEAR'] > 2000) & (LA_df['YEAR'] < 2021)]
KY_df = full_df.loc[((full_df['STATE_CODE'] == 'KY') | (full_df['EXPANSION'] == 0))]
KY_df = KY_df.loc[ (KY_df['YEAR'] < 2021) & (KY_df['YEAR'] > 2000) & (KY_df['YEAR'] < 2021)]
full_sc_df = full_df.loc[((full_df['STATE_CODE'].isin(['AR', 'LA', 'KY'])) | (full_df['EXPANSION'] == 0))]
full_sc_df = full_sc_df.loc[ (full_sc_df['YEAR'] < 2021) & (full_sc_df['YEAR'] > 2000) & (full_sc_df['YEAR'] < 2021)]

AR_outcomes = np.array(AR_df[['BINGE DRINKING OCC.', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='BINGE DRINKING OCC.'))
LA_outcomes = np.array(LA_df[['BINGE DRINKING OCC.', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='BINGE DRINKING OCC.'))
KY_outcomes = np.array(KY_df[['BINGE DRINKING OCC.', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='BINGE DRINKING OCC.'))
full_outcomes = np.array(full_sc_df[['BINGE DRINKING OCC.', 'STATE_CODE', 'YEAR']].pivot(index='STATE_CODE', columns='YEAR', values='BINGE DRINKING OCC.'))

AR_covariates = np.array(AR_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))
LA_covariates = np.array(LA_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))
KY_covariates = np.array(KY_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))
full_covariates = np.array(full_sc_df[['STATE_CODE', 'YEAR', 'SEX', 'WHITE', 'HISPANIC', 'BLACK', 'AGE_DUMMY_1', 'AGE_DUMMY_2', 'AGE_DUMMY_3', 'AGE_DUMMY_4', 'AGE_DUMMY_5', 'AGE_DUMMY_6', 'AGE_DUMMY_7', 'AGE_DUMMY_8', 'AGE_DUMMY_9', 'EMPLOY_DUMMY_1', 'EMPLOY_DUMMY_2', 'EMPLOY_DUMMY_3', 'EMPLOY_DUMMY_4', 'EMPLOY_DUMMY_5', 'EMPLOY_DUMMY_6', 'EMPLOY_DUMMY_7', 'EMPLOY_DUMMY_8', 'EMPLOY_DUMMY_9']].pivot(index='STATE_CODE', columns='YEAR'))

# indicate period in which treatment begins
AR_unit_treatment_periods = np.array([np.NaN if state != 'AR' else 13 for state in AR_df['STATE_CODE'].unique()])
LA_unit_treatment_periods = np.array([np.NaN if state != 'LA' else 15 for state in LA_df['STATE_CODE'].unique()])
KY_unit_treatment_periods = np.array([np.NaN if state != 'KY' else 13 for state in KY_df['STATE_CODE'].unique()])

full_unit_treatment_periods = np.array([np.NaN for state in full_sc_df['STATE_CODE'].unique()])
full_unit_treatment_periods[0] = 13
full_unit_treatment_periods[4] = 13
full_unit_treatment_periods[5] = 15

# estimate synthetic controls
results_AR = SparseSC.estimate_effects(AR_outcomes, AR_unit_treatment_periods, model_type='retrospective', w_pens=pens)
results_LA = SparseSC.estimate_effects(LA_outcomes, LA_unit_treatment_periods, model_type='retrospective', w_pens=pens)
results_KY = SparseSC.estimate_effects(KY_outcomes, KY_unit_treatment_periods, model_type='retrospective', w_pens=pens)
results_full = SparseSC.estimate_effects(full_outcomes, full_unit_treatment_periods, model_type='retrospective', w_pens=pens)

# export results, print path estimation with p-values
sc_vs_actual = pd.DataFrame({'AR':AR_outcomes[0], 'synthetic_AR':results_AR.get_sc()[0,:], 'LA':LA_outcomes[3], 'synthetic_LA':results_LA.get_sc()[3,:], 'KY':KY_outcomes[3], 'synthetic_KY':results_KY.get_sc()[3,:]})
sc_vs_actual.to_csv(output+"sc_vs_actual_drinking.csv")

print(results_AR)
print(results_LA)
print(results_KY)
print(results_full)


