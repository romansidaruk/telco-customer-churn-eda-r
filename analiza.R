# -----------------------------------------------------------------
# ETAP 1: Wczytanie i przygotowanie danych
# -----------------------------------------------------------------

# Ładowanie bibliotek
library(grid)
library(binom)
library(latex2exp)
library(ggplot2)
library(vctrs)
library(vcd)
library(DataExplorer)
library(ca)
library(Exact)
library(GGally)
library(exact2x2)
library(stats)
library(e1071)
library(kableExtra)
library(wooldridge)

# Wczytanie danych
df <-
  read.csv(header = TRUE, sep = ",", dec = ".", stringsAsFactors = TRUE,
           "WA_Fn-UseC_-Telco-Customer-Churn.csv")

# Badanie struktury
print("Struktura danych po wczytaniu:")
print(sapply(df, class))

# Konwersja SeniorCitizen na factor
df$SeniorCitizen <- as.factor(df$SeniorCitizen)

# Sprawdzenie wymiarów
print("Wymiary zbioru danych:")
print(dim(df))

# Usunięcie zbędnej kolumny
df <- subset(df, select = -customerID)

# Sprawdzenie brakujących wartości
print("Brakujące wartości w kolumnach:")
print(colSums(is.na(df)))

# -----------------------------------------------------------------
# ETAP 2: Analiza całej populacji
# -----------------------------------------------------------------

# Definicja własnej funkcji podsumowania 
my.summary <- function(X, na.rm = FALSE){
    wynik <- c(min(X, na.rm = na.rm), quantile(X,0.25, na.rm = na.rm),
               median(X,na.rm = na.rm), mean(X, na.rm = na.rm), 
               quantile(X,0.75, na.rm = na.rm),
               max(X, na.rm = na.rm), var(X, na.rm = na.rm),
               sd(X, na.rm = na.rm), IQR(X, na.rm = na.rm))
    names(wynik) <- c("min", "Q1", "median", "mean", "Q3", "max",
                      "var", "sd",
                      "IQR")
    return(wynik)
}

# Obliczenie statystyk sumarycznych dla zmiennych numerycznych
nazwy.wskaznikow <- names(my.summary(df$tenure, TRUE))
nazwy.zmiennych  <- c("tenure", "MonthlyCharges", "TotalCharges")
tenure.summary <- as.vector(my.summary(df$tenure, TRUE))
MonthlyCharges.summary <- as.vector(my.summary(df$MonthlyCharges, TRUE))
TotalCharges.summary <- as.vector(my.summary(df$TotalCharges, TRUE))
summary.matrix <- rbind(tenure.summary, MonthlyCharges.summary,
                        TotalCharges.summary)
row.names(summary.matrix) <- nazwy.zmiennych
colnames(summary.matrix)  <- nazwy.wskaznikow

# Wypisanie statystyk do konsoli
print("Statystyki sumaryczne dla całej populacji:")
print(summary.matrix)

# ----------------- Wizualizacja całej populacji -----------------

# Selekcja zmiennych numerycznych i kategorycznych
numer <- df[, sapply(df, is.numeric)] 
fac_vars <- df[, sapply(df, is.factor)] 

# Rysowanie histogramów (cała populacja)
plot_histogram(numer,  nrow=3, ncol=1)

# Rysowanie wykresów pudełkowych (cała populacja)
num_vars <- names(df)[sapply(df, is.numeric)]
par(mfrow = c(3, 1))
for (var in num_vars) {
  boxplot(df[[var]], main = paste("Boxplot dla", var), 
          ylab = var, col = "tomato", horizontal = TRUE)
}
par(mfrow = c(1, 1))

# Rysowanie wykresów słupkowych (cała populacja)
plot_bar(fac_vars, nrow = 6, ncol = 3)

# Rysowanie macierzy wykresów rozrzutu (cała populacja)
ggpairs(df[, c("tenure", "MonthlyCharges", "TotalCharges")])

# -----------------------------------------------------------------
# ETAP 3: Analiza Porównawcza (Churn vs No Churn)
# -----------------------------------------------------------------

# 1. Porównanie rozkładów zmiennych numerycznych (Histogramy)
plot_histogram(numer, by = "Churn")

# 2. Porównanie rozkładów zmiennych numerycznych (Boxploty)
plot_boxplot(numer, by = "Churn")

# 3. Porównanie rozkładów zmiennych kategorycznych (Słupkowe)
plot_bar(fac_vars, by = "Churn")
