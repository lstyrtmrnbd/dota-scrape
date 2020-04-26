#lang racket

(require marionette)

;;; Uniform Resource Locators

;; Example player matches page
(define cr1t-es "https://www.dotabuff.com/players/25907144/matches?hero=earth-spirit")

;; Example hero page
(define earth-spirit "https://www.dotabuff.com/heroes/earth-spirit")

;; Example match page
(define cr1t-es-match "https://www.dotabuff.com/matches/5375993843")

;;; Selectors

;; Player matches page

(define game-rows-selector ".content-inner > section:nth-child(1) > section:nth-child(2) > article:nth-child(1) > table:nth-child(1) > tbody:nth-child(2) > tr")

(define items-selector ".cell-xxlarge")
(define time-selector ".match-item-with-time > div > a > span")
(define image-selector ".match-item-with-time > div > a > img")

;; Hero page

(define top-player-selector ".col-4 > section:nth-child(4) > article:nth-child(2) > table:nth-child(1) > tbody:nth-child(2) > tr:nth-child(1) > td:nth-child(3) > a:nth-child(1)")

(define player-selector ".col-4 > section:nth-child(4) > article:nth-child(2) > table:nth-child(1) > tbody:nth-child(2) > tr")

;;; Scraping Strategies

(define (get-game-rows page)
  (page-query-selector-all! page game-rows-selector))

(define (get-item-rows game-rows)
  (map (lambda (e)
         (when e
           (element-query-selector! e items-selector)))
       game-rows))

(define (sanitize-time str)
  (if (void? str)
      0
      (string->number (string-trim str "m"))))

(define (get-item-info items-element)
  (let ((item-info-selector ".match-item-with-time > div > a")
        (time-selector "span")
        (image-selector "img"))
    (map (lambda (e)
           (let ((img (element-query-selector! e image-selector))
                 (span (element-query-selector! e time-selector)))
             (list (when img (element-attribute img "oldtitle"))
                   (sanitize-time (when span (element-text span))))))
         (element-query-selector-all! items-element item-info-selector))))

(define (get-all-game-items page)
  (map get-item-info (get-item-rows (get-game-rows page))))

;;; Scraping Work

(define profile "/home/skinner/.mozilla/firefox/rkgnx9wy.mari")

(define (scrape-items url)
  "Retrieves a list of items from a page of player matches"
  (call-with-marionette/browser/page!
   #:profile profile
   (lambda (p)
     (page-goto! p url)
     (page-wait-for! p items-selector #:timeout 10000)
     (get-all-game-items p))))

(define (scrape-top-players hero)
  (call-with-marionette/browser/page!
   #:profile profile
   (lambda (p)
     (page-goto! p url)
     (page-wait-for! p top-player-selector #:timeout 10000)
     (get-top-players p))))

;;; Structures & Analysis


;;; Interactive Scraping

;; Run a marionette enabled firefox instance and then
;; (define page
;;   (make-browser-page! (browser-connect!)))

;; (page-goto! page earth-spirit)

;; (element-text (page-query-selector! page top-player-selector))
