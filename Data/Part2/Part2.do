cd "D:\STATA\PRE Workshop coding exercise\Data\Part2"
use ira_tweets_csv_hashed, clear

// Convert data to usable format
gen date_time = clock(tweet_time, "YMD hm")
gen date = dofc(date_time)
format date %td
gen blm_check = regexm(tweet_text, "[Bb][Ll][Mm]|[Bb]lack *[Ll]i[vf]es* *[Mm]atters*")
tsset date

// Create day-level panel
collapse (count) tweetid (sum) reply_count like_count quote_count retweet_count blm_check, by(date)

// Make graph
tsline tweetid if tin(01jan2014,30may2018), lcolor(blue%50) || tsline reply_count if tin(01jan2014,30may2018), lcolor(red%50) || tsline quote_count if tin(01jan2014,30may2018), lcolor(green%50) xtitle("") legend(label(1 "Number of tweets") label(2 "Replies") label(3 "Quotes") symy(4pt) symx(4pt) row(1)) xlabel(, format(%tdCCYY)) name(g1)

tsline like_count if tin(1jan2014, 30may2018), lcolor(navy%70) || tsline retweet_count if tin(1jan2014, 30may2018), lcolor(orange%50) xtitle("") || tsline blm_check if tin(1jan2014, 30may2018), lcolor(black%30) ytitle("BLM counts", ax(2)) c(1) yaxis(2) xlabel(, format(%tdCCYY)) legend(label(1 "Likes") label(2 "Retweets") label(3 "BLM") symy(4pt) symx(4pt) row(1)) name(g2)

graph combine g1 g2, altshrink title(Evolution of tweets) saving(Graph1) // Daily data

// c) Regression
// Chronology: Sandra Bland 13 July 2015, Freddie Grey 19 August 2015, Alon Sterling 5 July 2016
foreach i in `=td(13july2015)' `=td(19august2015)' `=td(5july2016)' {
	gen X_`i' = 0
	replace X_`i' = 1 if date >= `i'
	foreach j in tweetid reply_count like_count quote_count retweet_count blm_check {
		reg `j' X_`i'
	}
}






