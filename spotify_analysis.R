# Harika Bulusu – Final Data 101 Project: Can Data Fool Us... or Make Us Famous?
# Dataset: Spotify Top 50 Songs (2019)
# Kaggle link: https://www.kaggle.com/datasets/leonardopena/top50spotify2019?

library(HypothesisTesting)
library(rpart)
library(rpart.plot)
library(arules)

#working directory
getwd()
setwd("C:\\Users\\bulus\\OneDrive\\Desktop\\Data 101")

#load dataset
spotify <- read.csv("top50.csv", stringsAsFactors = FALSE)
head(spotify)
str(spotify)

#Rename columns
names(spotify) <- c("track_name","artist","genre","bpm","energy","danceability",
                    "loudness","liveness","valence","duration_ms","acousticness",
                    "speechiness","popularity")

spotify$genre <- factor(spotify$genre)

#LONG vs SHORT
median_duration <- median(spotify$duration_ms)
spotify$is_long <- ifelse(spotify$duration_ms >= median_duration, "Long", "Short")
spotify$is_long <- factor(spotify$is_long)

#HIGH POPULARITY using median (correct for this dataset)
pop_threshold <- median(spotify$popularity)
spotify$high_pop <- ifelse(spotify$popularity >= pop_threshold, "High", "Low")
spotify$high_pop <- factor(spotify$high_pop)

#NEW VARIABLE (energy × valence)
spotify$vibe_score <- spotify$energy * spotify$valence

# 1. Languages of Data: Translating Raw Chaos into Meaning
table(spotify$genre)
summary(spotify$energy)
summary(spotify$popularity)
summary(spotify$vibe_score)

tapply(spotify$valence, spotify$genre, mean)
tapply(spotify$vibe_score, spotify$is_long, mean)

# 2. Exploratory Data Analysis: Seeing the Invisible
hist(spotify$popularity,
     main="Popularity Distribution",
     xlab="Popularity", col="skyblue")

boxplot(energy ~ genre, data=spotify, las=2,
        main="Energy by Genre", col="orange")

# 3. Fooled by Data - Randomness/Shuffling
real_diff <- mean(spotify$popularity[spotify$is_long=="Long"]) -
  mean(spotify$popularity[spotify$is_long=="Short"])

set.seed(101)
shuffled <- sample(spotify$is_long)

shuf_diff <- mean(spotify$popularity[shuffled=="Long"]) -
  mean(spotify$popularity[shuffled=="Short"])

real_diff
shuf_diff

# 4. Central Limit Theorem + Confidence Interval
set.seed(10)
means <- replicate(1000, mean(sample(spotify$energy, 30, replace=TRUE)))

hist(means,
     main="Sampling Distribution of Mean ENERGY (n = 30)",
     xlab="Sample Mean Energy",
     col="lightblue")

long_songs <- subset(spotify, is_long=="Long")
n <- nrow(long_songs)
mean_pop <- mean(long_songs$popularity)
sd_pop <- sd(long_songs$popularity)
sem <- sd_pop / sqrt(n)
z_score <- 1.96
moe <- z_score * sem
ci_lower <- mean_pop - moe
ci_upper <- mean_pop + moe

round(c(n=n, mean=mean_pop, SD=sd_pop, SEM=sem, MOE=moe, LCL=ci_lower, UCL=ci_upper), 3)

# 5. Hypothesis Testing (z-test + Permutation Test)
long_songs <- subset(spotify, is_long=="Long")
short_songs <- subset(spotify, is_long=="Short")

mean_long <- mean(long_songs$popularity)
mean_short <- mean(short_songs$popularity)
diff_means <- mean_long - mean_short

cat("Observed difference in means (Long - Short):", diff_means, "\n")

z_result <- z_test_from_data(spotify,'is_long','popularity','Short','Long')
cat("Z-test p-value:", z_result, "\n")

perm_result <- permutation_test(spotify,'is_long','popularity',10000,'Short','Long')
cat("Permutation p-value:", perm_result, "\n")

# 6. Independence & Difference of Proportions (Chi-Square)
median_energy <- median(spotify$energy)
spotify$high_energy <- ifelse(spotify$energy >= median_energy, "High", "Low")
spotify$high_energy <- factor(spotify$high_energy)

tab <- table(spotify$high_energy, spotify$high_pop)
tab

chisq_res <- chisq.test(tab)
chisq_res
chisq_res$observed
chisq_res$expected

# 7. Multiple Hypothesis Testing: The False Discovery Jungle
overall_valence <- mean(spotify$valence)
genres <- levels(spotify$genre)

genre_counts <- table(spotify$genre)
valid_genres <- names(genre_counts[genre_counts >= 2])

p_vals <- sapply(valid_genres, function(g){
  x <- spotify$valence[spotify$genre == g]
  t.test(x, mu=overall_valence)$p.value
})

p_bonf <- p.adjust(p_vals, method="bonferroni")
p_bh   <- p.adjust(p_vals, method="BH")

multi_results <- data.frame(
  genre=valid_genres,
  p_raw=round(p_vals,4),
  bonferroni=round(p_bonf,4),
  BH=round(p_bh,4)
)

multi_results[order(multi_results$p_raw), ]

# 8. Bayesian Reasoning: Updating Beliefs
PriorP <- mean(spotify$high_energy=="High")
PriorOdds <- PriorP / (1-PriorP)

TP <- sum(spotify$high_energy=="High" & spotify$high_pop=="High") /
  sum(spotify$high_energy=="High")

FP <- sum(spotify$high_energy=="Low" & spotify$high_pop=="High") /
  sum(spotify$high_energy=="Low")

LR <- TP / FP
PostOdds <- PriorOdds * LR
PostP <- PostOdds/(1+PostOdds)

PriorP
TP
FP
LR
PostP
PostP/PriorP

# 9. Prediction Models: From Correlation to Prediction
set.seed(123)

# make sure bpm is numeric for the tree
spotify$bpm <- as.numeric(spotify$bpm)

train_idx <- sample(1:nrow(spotify), size=0.7*nrow(spotify))
train <- spotify[train_idx, ]
test  <- spotify[-train_idx, ]

tree_model <- rpart(high_pop ~ energy + danceability + valence + bpm,
                    data=train, method="class")

train_pred <- predict(tree_model, train, type="class")
train_acc <- mean(train_pred == train$high_pop)

test_pred <- predict(tree_model, test, type="class")
test_acc <- mean(test_pred == test$high_pop)

cat("Training Accuracy:", round(train_acc*100,2), "%\n")
cat("Testing Accuracy:", round(test_acc*100,2), "%\n")

rpart.plot(tree_model, main="Decision Tree: Predicting High Popularity")

# 10. Association Rules & Lift: The Hidden Recipes
rules_df <- data.frame(
  HighEnergy = spotify$energy >= median(spotify$energy),
  HighDance  = spotify$danceability >= median(spotify$danceability),
  HighVal    = spotify$valence >= median(spotify$valence),
  HighPop    = spotify$high_pop=="High"
)

rules_df <- as.data.frame(lapply(rules_df, as.logical))
trans <- as(rules_df, "transactions")

rules <- apriori(trans,parameter=list(supp=0.1, conf=0.6, minlen=2))

strong_rules <- subset(rules, lift > 1)
inspect(strong_rules)

