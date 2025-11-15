# -----------------------------------------------------------------
# ETAP 1: Wczytanie i przygotowanie danych
# -----------------------------------------------------------------

# Ładowanie bibliotek [cite: 2]
library(grid)
library(knitr)
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
library(xtable)

# Ustawienia globalne chunków (opcjonalne poza Rnw) [cite: 2]
opts_chunk$set(fig.path='figure/', fig.align='center', fig.pos='H')

# Wczytanie danych 
# UWAGA: Zmień tę ścieżkę na względną! (np. "WA_Fn-UseC_-Telco-Customer-Churn.csv")
df <-
  read.csv(header = TRUE, sep = ",", dec = ".", stringsAsFactors = TRUE,
           "WA_Fn-UseC_-Telco-Customer-Churn.csv")

# Badanie struktury [cite: 7]
sapply(df, class)

# Konwersja SeniorCitizen na factor [cite: 9]
df$SeniorCitizen <- as.factor(df$SeniorCitizen)
is.factor(df$SeniorCitizen)

# Sprawdzenie wymiarów [cite: 10]
dim(df)

# Ponowne sprawdzenie typów zmiennych [cite: 12]
sapply(df, class)

# Usunięcie zbędnej kolumny [cite: 13]
df <- subset(df, select = -customerID)

# Sprawdzenie brakujących wartości [cite: 15]
colSums(is.na(df))

# -----------------------------------------------------------------
# ETAP 2: Analiza całej populacji
# -----------------------------------------------------------------

# Definicja własnej funkcji podsumowania [cite: 18, 19]
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

# Obliczenie statystyk sumarycznych [cite: 20]
nazwy.wskaznikow <- names(my.summary(df$tenure, TRUE))
nazwy.zmiennych  <- c("tenure", "MonthlyCharges", "TotalCharges")
tenure.summary <- as.vector(my.summary(df$tenure, TRUE))
MonthlyCharges.summary <- as.vector(my.summary(df$MonthlyCharges, TRUE))
TotalCharges.summary <- as.vector(my.summary(df$TotalCharges, TRUE))
summary.matrix <- rbind(tenure.summary, MonthlyCharges.summary,
                        TotalCharges.summary)
row.names(summary.matrix) <- nazwy.zmiennych
colnames(summary.matrix)  <- nazwy.wskaznikow

# Kod do generowania tabeli LaTeX (w R wypisze kod do konsoli) [cite: 20]
x <- matrix(summary.matrix, ncol = 9, nrow =3, byrow = FALSE)
tabela_1 <- xtable(x,digits = 1, label ='tab_1')
rownames(tabela_1) <- c("tenure", "MonthlyCharges", "TotalCharges")
colnames(tabela_1) <- names(my.summary(df$tenure, TRUE))
print(tabela_1, type ='latex', table.placement ='H',
      caption.placement ='top')

# Rysowanie histogramów [cite: 21]
numer <- df[, sapply(df, is.numeric)] 
plot_histogram(numer,  nrow=3, ncol=1)

# Rysowanie wykresów pudełkowych [cite: 21]
num_vars <- names(df)[sapply(df, is.numeric)]
par(mfrow = c(3, 1))
for (var in num_vars) {
  boxplot(df[[var]], main = paste(var), 
          ylab = var, col = "tomato")
}
par(mfrow = c(1, 1))

# Rysowanie wykresów słupkowych [cite: 22]
fac_vars <- df[, sapply(df, is.factor)] 
plot_bar(fac_vars, nrow = 6, ncol = 3)

# Rysowanie macierzy wykresów rozrzutu [cite: 22]
ggpairs(df[, c("tenure", "MonthlyCharges", "TotalCharges")])

# -----------------------------------------------------------------
# ETAP 3: Analiza w podgrupach (Churn vs No Churn)
# -----------------------------------------------------------------

# Podział na podzbiory [cite: 50]
df_churn_yes <- df[df$Churn == "Yes", ]  
df_churn_no <- df[df$Churn == "No", ]

# --- Analiza grupy CHURN = YES ---

# Statystyki sumaryczne (Churn=Yes) [cite: 51]
nazwy.wskaznikow <- names(my.summary(df_churn_yes$tenure, TRUE))
nazwy.zmiennych  <- c("tenure", "MonthlyCharges", "TotalCharges")
tenure.summary <- as.vector(my.summary(df_churn_yes$tenure, TRUE))
MonthlyCharges.summary <- as.vector(my.summary(df_churn_yes$MonthlyCharges, TRUE))
TotalCharges.summary <- as.vector(my.summary(df_churn_yes$TotalCharges, TRUE))
summary.matrix <- rbind(tenure.summary, MonthlyCharges.summary,
                        TotalCharges.summary)
row.names(summary.matrix) <- nazwy.zmiennych
colnames(summary.matrix)  <- nazwy.wskaznikow

# Kod do tabeli LaTeX (Churn=Yes) [cite: 51]
x <- matrix(summary.matrix, ncol = 9, nrow = 3, byrow = FALSE)
tabela_2 <- xtable(x,digits = 1, label ='tab_2')
rownames(tabela_2) <- c("tenure", "MonthlyCharges", "TotalCharges")
colnames(tabela_2) <- names(my.summary(df_churn_yes$tenure, TRUE))
print(tabela_2, type ='latex', table.placement ='H',
      caption.placement ='top')

# Histogramy (Churn=Yes) [cite: 52]
numer <- df_churn_yes[, sapply(df_churn_yes, is.numeric)] 
plot_histogram(numer,  nrow=3, ncol=1)

# Wykresy pudełkowe (Churn=Yes) [cite: 52]
num_vars <- names(df_churn_yes)[sapply(df_churn_yes, is.numeric)]
par(mfrow = c(2, 2))
for (var in num_vars) {
  boxplot(df_churn_yes[[var]], main = paste(var), 
          ylab = var, col = "tomato")
}
par(mfrow = c(1, 1))

# Wykresy słupkowe (Churn=Yes) [cite: 53]
fac_vars <- df_churn_yes[, sapply(df_churn_yes, is.factor)] 
plot_bar(fac_vars, nrow = 6, ncol = 3)

# Macierz rozrzutu (Churn=Yes) [cite: 53]
ggpairs(df_churn_yes[, c("tenure", "MonthlyCharges", "TotalCharges")])


# --- Analiza grupy CHURN = NO ---

# Statystyki sumaryczne (Churn=No) [cite: 77]
nazwy.wskaznikow <- names(my.summary(df_churn_no$tenure, TRUE))
nazwy.zmiennych  <- c("tenure", "MonthlyCharges", "TotalCharges")
tenure.summary <- as.vector(my.summary(df_churn_no$tenure, TRUE))
MonthlyCharges.summary <- as.vector(my.summary(df_churn_no$MonthlyCharges, TRUE))
TotalCharges.summary <- as.vector(my.summary(df_churn_no$TotalCharges, TRUE))
summary.matrix <- rbind(tenure.summary, MonthlyCharges.summary,
                        TotalCharges.summary)
row.names(summary.matrix) <- nazwy.zmiennych
colnames(summary.matrix)  <- nazwy.wskaznikow

# Kod do tabeli LaTeX (Churn=No) [cite: 77]
x <- matrix(summary.matrix, ncol = 9, nrow = 3, byrow = FALSE)
tabela_3 <- xtable(x, digits = 1, label ='tab_3')
rownames(tabela_3) <- c("tenure", "MonthlyCharges", "TotalCharges")
colnames(tabela_3) <- names(my.summary(df_churn_no$tenure, TRUE))
print(tabela_3, type ='latex', table.placement ='H',
      caption.placement ='top')

# Histogramy (Churn=No) [cite: 78]
numer <- df_churn_no[, sapply(df_churn_no, is.numeric)] 
plot_histogram(numer, nrow=3, ncol=1)

# Wykresy pudełkowe (Churn=No) [cite: 78]
num_vars <- names(df_churn_no)[sapply(df_churn_no, is.numeric)]
par(mfrow = c(3, 1))
for (var in num_vars) {
  boxplot(df_churn_no[[var]], main = paste(var), 
          ylab = var, col = "tomato")
}
par(mfrow = c(1, 1))

# Wykresy słupkowe (Churn=No) [cite: 79]
fac_vars <- df_churn_no[, sapply(df_churn_no, is.factor)] 
plot_bar(fac_vars, nrow = 6, ncol = 3)

# Macierz rozrzutu (Churn=No) [cite: 79]
ggpairs(df_churn_no, c("tenure", "MonthlyCharges", "TotalCharges"))

# --- Porównanie obu grup ---

# Wykresy słupkowe skategoryzowane po 'Churn' [cite: 108]
plot_bar(df[, sapply(df, is.factor)], by = "Churn")