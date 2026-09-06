import pandas as pd
from scipy import stats

# Load the CSV you exported from pgAdmin
df = pd.read_csv('home_circuit_advantage.csv')

# Paired t-test: compares each driver's home-race average against their
# own away-race average. "Paired" matters here -- we're not comparing two
# independent groups of drivers, we're comparing each driver to themself,
# which controls for the fact that some drivers are just faster overall.
t_stat, p_value = stats.ttest_rel(df['avg_finish_home'], df['avg_finish_away'])

print(f"Mean home finish: {df['avg_finish_home'].mean():.2f}")
print(f"Mean away finish: {df['avg_finish_away'].mean():.2f}")
print(f"Mean advantage:   {df['home_advantage'].mean():.2f} positions")
print(f"t-statistic:      {t_stat:.3f}")
print(f"p-value:          {p_value:.6f}")

if p_value < 0.05:
    print("\nResult: statistically significant at the 95% confidence level.")
    print("Drivers finish meaningfully better at their home race than elsewhere.")
else:
    print("\nResult: not statistically significant -- the apparent home")
    print("advantage could plausibly be due to chance / sample noise.")
