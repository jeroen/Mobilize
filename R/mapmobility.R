mapmobility <- function(date, username,...){
	library(maps);
	mobility <- oh.mobility.read(date=date, username=username,...);
	map("county", "california");
	lines(mobility$lo, mobility$la, type="l", col="red", lwd=10);
}
