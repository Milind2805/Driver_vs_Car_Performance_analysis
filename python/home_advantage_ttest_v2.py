import pandas as pd
from scipy import stats

df = pd.read_csv('home_advantage_established.csv')

t_stat, p_value = stats.ttest_rel(df['avg_finish_home'], df['avg_finish_away'])

print(f"Drivers in sample:  {len(df)}")
print(f"Mean home finish:   {df['avg_finish_home'].mean():.2f}")
print(f"Mean away finish:   {df['avg_finish_away'].mean():.2f}")
print(f"Mean advantage:     {df['home_advantage'].mean():.2f} positions")
print(f"t-statistic:        {t_stat:.3f}")
print(f"p-value:            {p_value:.6f}")

if p_value < 0.05:
    print("\nResult: statistically significant at the 95% confidence level.")
    print("Among established drivers (10+ home races), home advantage is real.")
else:
    print("\nResult: still not statistically significant.")
