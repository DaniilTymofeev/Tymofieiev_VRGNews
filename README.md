# Tymofieiev_VRGNews
# 📰 Tymofieiev\_VRGNews

*Test task for VRG Soft*

![UI](https://img.shields.io/badge/UI-SwiftUI-purple)
![DB](https://img.shields.io/badge/DB-Realm-red)
![ThirdParty](https://img.shields.io/badge/Libraries-SPM-green)

---

## 1. Test Task

The original test task included the following requirements:

[TestTask_DEV_iOS_A4_PDF.pdf](https://github.com/user-attachments/files/22454885/TestTask_DEV_iOS_A4_PDF.pdf)

<img width="824" height="267" alt="image" src="https://github.com/user-attachments/assets/737e20e4-acd3-4c64-81b1-f2de88c30b0c" />


---

## 2. My Interpretation

I approached the task with the following stack and decisions:

* **Architecture**: MVVM + Repository pattern (it's redundant to make it more complex)
* **Persistence**: Realm database for offline caching and fast access (using it as single source of truth, no other needed)
* **Networking**: URLSession for API requests (though about Alamofire, but still decided to put it light)
* **UI**: Combination of SwiftUI and minimal UIKit usage (SwiftUI is more modern, clean and also I like it)
* **My Vision**:
I saw this APP as SwiftUI quick, sharp and minimalistic but with some UI/UX flavor with images, animation. For navigation I sticked with native TabBar because it meets all my expectatios for usability and ui look (also used navigation to web browser because we have links in those News responses). Realm is simple, familiar and flexible for using only 1 model with little alterations to filter through saved objects and show on both screens. Pagination works on both screen, doing safe calculation when to load and when to stop.

I implmeneted a convenient file structure, added resources, formatters for strings, paginations for lists, timestamps to load from Realm properly.

SearchNews screen: we have initial load with 'ukraine' as search keyword; user can scroll with pagination, use pull-to-refresh with inputed keyword, search any string news; to go back to the top of the list just tap at the same tabbar item; every successful search will clear all instances of News in Relam with searchedKeyword != nil and save new ones.

Categories screen: we can load only US related news by selected category; initial category is 'general'; basic loads and refresh are as on SearchNews screen;

---

## 3. Troubles Along the Way

Some of the challenges and decisions during development:
I've found a lot of restrictions in API that i needed to handle for the good UX
1. API returning items with pagination in sortByPublishDate (the newest on top), but on the next page we might recieve even newer items sorted only relatively to that page (RESOLVING: i decided to leave pagination as it is, as we receive items from server, because if let there be filter - user could scroll 2-4 pages and then when scrolled to the top he would see completly different picture - inconvenient)

2. API returning at categories incorect amount of items in pages (page=1, PageSize=20 >>> returns size=18, totalItems=48), this broke my pagination logic at first because i expected always to be 10/20 if total items are exceeding those numbers.

3. Saving last keyword and selected category - (RESOLVING: decide not to use UserDefaults and just make additional fileds in Realm)

Future improvements:

What can be improved: we could use more of API functionality like sorting, choosing language; we could use SwiftGen for safe-keeping our images and strings better, possible localizations; always we always can make UI/UX better; UnitTest and additional error handlings

---

## 4. Screenshots & Demos

📱 Search News 
(pagination, pull to refresh, tap on news redirect)

https://github.com/user-attachments/assets/ff78ba9f-e973-4903-ae6f-39b463ecbdeb

(search, pull to refresh, refresh default key 'ukraine')

https://github.com/user-attachments/assets/5428cd18-d837-40e7-9e36-8e3c01631152



📱 Categories Screen
(pagination, pull to refresh)

https://github.com/user-attachments/assets/633c17c7-5b73-48f4-bdc2-68b9d7372501


(change category)

https://github.com/user-attachments/assets/d07aa141-05ad-42af-9732-d225d4e5fae1



📱 Realm for both screens

https://github.com/user-attachments/assets/428c9c7a-3b18-4751-8783-981f1d2b4b9b



---

## 🙏 Thanks

Big thanks to **VRG Soft** for the opportunity 🙌

---

## 🔗 Useful Links

* [Swift](https://swift.org/)
* [Realm](https://realm.io/)
* [SwiftLint](https://github.com/realm/SwiftLint)
* [Lottie](https://github.com/airbnb/lottie-ios)
