
// Project: COGS197_Demo 
// Created: 2015-10-28

// set window properties
SetWindowTitle( "COGS197_Demo" )
SetWindowSize( 1080, 1920, 0 )
SetClearColor(255,255,255)
Global Width = 1080
Global Height = 1920

// set display properties
SetVirtualResolution( 1080, 1920 )
SetOrientationAllowed( 1, 1, 0, 0 )

Global white = 0
white = MakeColor(255,255,255)
Global blue = 0
blue = MakeColor(82,100,212)
Global black = 0
black = MakeColor(0,0,0)
Global grey = 0
grey = MakeColor(80,80,80)

Global demo_version = 0
Global username$ = "Jeffrey"
Global sessionID = 0
Global screen_state = 0
Global map_state = 0

type eventVar
	hostID as integer
	title as String
	location as String
	date as integer //Use unix
	ID as integer
	cur_n as integer
	max_n as integer
	desc as String
	image
	attendee_ID as integer[]
endtype

Global eventLists as eventVar[]
for i=0 to eventLists.length
	eventLists[i].ID = -1
next i

type card
	eventID as integer
	index as integer
	title
	date
	loc
	num_attend
	image
	desc
	tags as String[]
	sprite
	offset as integer
	selected as integer
endtype

type short_card
	eventID as integer
	hostID as integer
	title
	date
	loc
	sprite
	offset as integer
endtype

type profile
	ID as integer
	name as String
	gender as String
	age as integer
	hobbies as String
	hosting as eventVar[]
	bookmarked as eventVar[]
	attending as eventVar[]
	history as eventVar[]
	image
endtype

Global profileList as profile[]
Global short_cardList as short_card[]
Global cardList as card[3]

//Global Sprite Variables, images
Global nav_profile = 0
Global nav_home = 0
Global nav_search = 0
Global nav_create = 0

//Global Non-Sprite Variables
Global current_c_index = 0
Global card_offset = -90
Global temp_offset = 0
Global temp2_offset = -90
Global expand_offset = 0
Global init_x = 0
Global init_y = 0
Global transition = 0
Global c_created = 0 //Checks if texts and sprites for Create Screen is created
Global p_created = 0 //Checks if texts and sprites for Profile Screen is created
Global p_tab = 1 //0 = hosting, 1 = attending, 2 = bookmarked, 3 = history


loadSplashScreen()
//selectVersion()
showLogIn()
LoadSpriteGlobals()

do
	
	if transition = 0
		select screen_state  //0=home, 1=expanded view, 2=profile, 3=create, 4=search
			case 0:
				if GetPointerPressed() = 1
					init_x = ScreenToWorldX(GetPointerX())
					init_y = ScreenToWorldY(GetPointerY())
					
					//check for menu button press
					if GetSpriteHitTest(nav_profile ,init_x,init_y)
						screen_state = 2
						temp = LoadImage("images/nav_home.png")
						SetSpriteImage(nav_home, temp)
						temp = LoadImage("images/nav_profile_A.png")
						SetSpriteImage(nav_profile, temp)
						LoadProfileScreen()
						Sync()
					elseif GetSpriteHitTest(nav_create ,init_x,init_y)
						screen_state = 3
						temp = LoadImage("images/nav_home.png")
						SetSpriteImage(nav_home, temp)
						temp = LoadImage("images/nav_create_A.png")
						SetSpriteImage(nav_create, temp)
						LoadCreateScreenGlobals()
						Sync()
					elseif GetSpriteHitTest(nav_search ,init_x,init_y)
						
					endif
				elseif GetPointerState() = 1
					if init_y > 120
						if temp_offset = 0
							temp_offset = temp2_offset
						endif
						temp2_offset = temp_offset - GetPointerX() + init_x
						if GetPointerX()-init_X > 100 and card_offset > -90
							transition = 1
							temp_offset = 0
							dec current_c_index
							snap(-1)
							transition = 0
						elseif GetPointerX()-init_X < -100 and card_offset < -90+950*(eventLists.length)
							transition = 1
							temp_offset = 0
							inc current_c_index
							snap(1)
							transition = 0
						endif
						
					endif
				elseif GetPointerReleased() = 1
					if transition = 0 and abs(init_x-GetPointerX()) <20
						if GetSpriteHitGroup(1, init_x, init_y)
							SetSpriteDepth(cardList[0].sprite, 9)
							SetSpriteDepth(cardList[0].image, 9)
							expandCard(cardList[0])
							screen_state = 1
						elseif GetSpriteHitGroup(2, init_x, init_y)
							SetSpriteDepth(cardList[1].sprite, 9)
							SetSpriteDepth(cardList[1].image, 9)
							expandCard(cardList[1])
							screen_state = 1
						elseif GetSpriteHitGroup(3, init_x, init_y)
							SetSpriteDepth(cardList[2].sprite, 9)
							SetSpriteDepth(cardList[2].image, 9)
							expandCard(cardList[2])
							screen_state = 1
						endif
					endif
					temp_offset = 0
				endif
				if screen_state = 0
					updateCards()
				endif
			endcase
			
			
			case 1:
				if GetPointerPressed() = 1
					init_x = ScreenToWorldX(GetPointerX())
					init_y = ScreenToWorldY(GetPointerY())
					
					//check for menu button press
					if GetSpriteHitTest(nav_profile ,init_x,init_y)
						collapseCard(cardList[i])
						screen_state = 2
						temp = LoadImage("images/nav_home.png")
						SetSpriteImage(nav_home, temp)
						temp = LoadImage("images/nav_profile_A.png")
						SetSpriteImage(nav_profile, temp)
						LoadProfileScreen()
						Sync()
					elseif GetSpriteHitTest(nav_home ,init_x,init_y)
						for i=0 to 2
							if cardList[i].selected = 1
								collapseCard(cardList[i])
								screen_state = 0
								exit
							endif
						next i
					elseif GetSpriteHitTest(nav_create ,init_x,init_y)
						for i=0 to 2
							if cardList[i].selected = 1
								collapseCard(cardList[i])
								screen_state = 3
								temp = LoadImage("images/nav_home.png")
								SetSpriteImage(nav_home, temp)
								temp = LoadImage("images/nav_create_A.png")
								SetSpriteImage(nav_create, temp)
								LoadCreateScreenGlobals()
								Sync()
								exit
							endif
						next i
					elseif GetSpriteHitTest(nav_search ,init_x,init_y)
						
					endif

				elseif GetPointerState() = 1
					if init_y > 120
						if temp_offset = 0
							temp_offset = expand_offset
						endif
						if temp_offset + ScreenToWorldY(GetPointerY()) - init_y <= 0
							expand_offset = temp_offset + ScreenToWorldY(GetPointerY()) - init_y
						else
							expand_offset = 0
						endif
					endif
				elseif GetPointerReleased() = 1
					if abs(init_y - GetPointerY()) < 15
						collapseCard(cardList[mod(current_c_index, 3)])
						screen_state = 0
					endif
					temp_offset=0
				endif
				updateCards()
			endcase
			
			case 2:
				ProfileScreenLoop()
			endcase
			
			case 3:
				CreateScreenLoop()
			endcase
			

		endselect
	endif
    Print( ScreenFPS())
loop
Function loadSplashScreen()
	i_logo = LoadImage("images/logo.png")
	logo = CreateSprite(i_logo)
	SetSpriteSize(logo,400,-1)
	SetSpritePosition(logo,540-GetSpriteWidth(logo)/2,960-GetSpriteHeight(logo)/2)
	SetSpriteVisible(logo,1)
	SetSpriteDepth(logo, 0)
	SetSpriteSize(logo,400,-1)
	count = 0
	Sync()
	do
		sleep(10)
		print(ScreenFPS())
		if count>3 //default 150
			DeleteImage(i_logo)
			DeleteSprite(logo)
			ClearScreen()
			exit
		endif
		Sync()
		count = count+1
	loop
endfunction
Function showLogIn()
	image = LoadImage("images/bg-login.jpg")
	background = CreateSprite(image)
	inputUN = CreateText("Username")
	inputPS = CreateText("Password")
	SetTextVisible(inputUN, 1)
	SetTextVisible(inputPS, 1)
	SetTextSize(inputUN, 50)
	setTextSize(inputPS, 50)
	SetTextColor(inputUN, 245,123,108,255)
	SetTextColor(inputPS, 245,123,108,255)
	SetTextPosition(inputUN, 95, 1250)
	SetTextPosition(inputPS, 95, 1390)
	
	//buttons
	image = LoadImage("images/login_fb.png")
	b_fb = CreateSprite(image)
	SetSpritePosition(b_fb, 540-385, 945)
	SetSpriteVisible(b_fb, 1)
	image = LoadImage("images/login_signup.png")
	b_signup = CreateSprite(image)
	SetSpritePosition(b_signup, 540-355, 1570)
	SetSpriteVisible(b_signup, 1)
	image = LoadImage("images/login_login.png")
	b_login = CreateSprite(image)
	SetSpritePosition(b_login, 540+355-260, 1570)
	SetSpriteVisible(b_login, 1)

	SetSpriteDepth(background, 100)
	SetSpriteVisible(background,1)
	SetSpritePosition(background, 0,0)
	
	sessionID = 1
	do
		if GetPointerPressed() = 1
			_x = ScreenToWorldX(GetPointerX())
			_y = ScreenToWorldY(GetPointerY())
			if _x > 95 and _x < 680
				if _y > 1250 and _y < 1300
					SetTextString(inputUN, Input("", 30))
					SetTextVisible(inputUN, 1)
					if not GetTextString(inputUN) = ""
						username$ = GetTextString(inputUN)
					endif
					Sync()
				elseif _y > 1390 and _y < 1440
					SetTextString(inputPS, Input("", 30))
					temp$ = ""
					for i=1 to len(GetTextString(inputPS))
						temp$ = temp$ + "*"
					next i
					SetTextString(inputPS, temp$)
					SetTextVisible(inputPS, 1)
					Sync()
				endif
			endif
			if GetSpriteHitTest(b_signup, _x, _y)
				//signup()
			elseif GetSpriteHitTest(b_fb, _x, _y)
				ClearScreen()
				DeleteAllObjects()
				DeleteAllSprites()
				DeleteAllText()
				Sync()
				exit
			elseif GetSpriteHitTest(b_login, _x, _y)
				ClearScreen()
				DeleteAllObjects()
				DeleteAllSprites()
				DeleteAllText()
				Sync()
				exit
			endif
		endif
		Sync()
	loop
	
	
endfunction
Function LoadSpriteGlobals()
	
	//load navigation buttons
	nav_profile = CreateSprite(LoadImage("images/nav_profile.png"))
	SetSpritePosition(nav_profile,0,0)
	SetSpriteVisible(nav_profile, 0)
	nav_home = CreateSprite(LoadImage("images/nav_home_A.png"))
	SetSpritePosition(nav_home,270*1,0)
	SetSpriteVisible(nav_home, 0)
	nav_create = CreateSprite(LoadImage("images/nav_create.png"))
	SetSpritePosition(nav_create,270*2,0)
	SetSpriteVisible(nav_create, 0)
	nav_search = CreateSprite(LoadImage("images/nav_search.png"))
	SetSpritePosition(nav_search, 270*3, 0)
	SetSpriteVisible(nav_search, 0)
	SetSpriteDepth(nav_profile, 1)
	SetSpriteDepth(nav_home, 1)
	SetSpriteDepth(nav_create, 1)
	SetSpriteDepth(nav_search, 1)
	
	_temp as eventVar
	
	//load predefined events
	_temp.title = "Dinner at Rock Bottom!"
	_temp.ID = 1
	_temp.cur_n = 1
	_temp.max_n = 5
	_temp.date = GetUnixFromDate(2015,12,1,15,30,00)
	_temp.desc = "Just wanted to get some people together to try out the new late night happy hour specials that Rock Bottom has been having, but I didn't want to go alone. Anyone is welcome, but I'd like to keep the size down to one table."
	_temp.hostID = 2
	_temp.image = LoadImage("images/rb.jpg")
	_temp.location = "1234 Rock Bottom Street"
	eventLists.insert(_temp)
	
	_temp.title = "BBQ at La Jolla Coves"
	_temp.ID = 2
	_temp.cur_n = 3
	_temp.max_n = 20
	_temp.date = GetUnixFromDate(2015,12,4,11,0,00)
	_temp.desc = "Let's get ready to be festive! Winter break is coming up and this is a great way to destress before finals/ after finals!"
	_temp.hostID = 1
	_temp.image = LoadImage("images/lc.png")
	_temp.location = "1234 La Jolla Beach Cove Place"
	eventLists.insert(_temp)
	
	_temp.title = "Bowling at KC Bowl"
	_temp.ID = 3
	_temp.cur_n = 4
	_temp.max_n = 5
	_temp.date = GetUnixFromDate(2015,12,20,18,0,0)
	_temp.desc = "Let's bowl the night away! :)"
	_temp.hostID = 4
	_temp.image = LoadImage("images/bowling.png")
	_temp.location = "1234 Rock Bottom Street"
	eventLists.insert(_temp)
	
	_temp.title = "Netflix and Socialize!"
	_temp.ID = 4
	_temp.cur_n = 7
	_temp.max_n = 30
	_temp.date = GetUnixFromDate(2015,1,3,20,0,0)
	_temp.desc = "Hey! I am having a small get together at The Park in San Diego. There will be snacks and drinks (non-alcoholic). We will be having a viewing of the Netflix original show, Sense8. We will watch the newest episode and it will be awesome! Please bring your own blankets and chairs unless you don't mind sitting on the grass (might be a little wet). I will have a huge 30 foot screen set-up and it will be an awesome night. See all of you there!"
	_temp.hostID = 3
	_temp.image = LoadImage("images/bowling.png")
	_temp.location = "1234 Rock Bottom Street"
	eventLists.insert(_temp)
	
	for i=0 to 2
		cardList[i].sprite = CreateSprite(LoadImage("images/card_bg.png"))
		cardList[i].image = CreateSprite(LoadImage(""))
		cardList[i].title = CreateText("")
		cardList[i].loc = CreateText("")
		cardList[i].date = CreateText("")
		cardList[i].num_attend = CreateText("")
		cardList[i].desc = CreateText("")
		SetSpriteSize(cardList[i].sprite, 900, 1325)
		SetTextSize(cardList[i].title, 60)
		SetTextSize(cardList[i].date, 30)
		SetTextSize(cardList[i].loc, 30)
		SetTextSize(cardList[i].desc, 30)
		SetTextSize(cardList[i].num_attend, 45)
		SetTextColor(cardList[i].title, 0,0,0,255)
		SetTextColor(cardList[i].date, 0,0,0,255)
		SetTextColor(cardList[i].loc, 0,0,0,255)
		SetTextColor(cardList[i].desc, 0,0,0,255)
		SetTextColor(cardList[i].num_attend, 0,0,0,255)
		SetTextMaxWidth(cardList[i].title,820)
		SetTextMaxWidth(cardList[i].date,820)
		SetTextMaxWidth(cardList[i].loc,820)
		SetTextMaxWidth(cardList[i].desc,820)
		SetTextMaxWidth(cardList[i].num_attend,820)
		SetSpriteGroup(cardList[i].sprite, i+1)
		SetSpriteGroup(cardList[i].image, i+1)
		cardList[i].selected = 0
		SetTextVisible(cardList[i].title, 1)
		cardList[i].index = i
	next i
	
	//load initial cards
	LoadCard(cardList[0], eventLists[0], 0)
	LoadCard(cardList[1], eventLists[1], 950)
	LoadCard(cardList[2], eventLists[2], 950*2)
	current_c_index = 0
	
	//Load Fake Profiles and "Ryan" profile
	_temp2 as profile
	
	//Terry Cho
	_temp2.ID = 1
	_temp2.name = "Terry Cho"
	_temp2.gender = "Male"
	_temp2.age = 19
	_temp2.hobbies = "Fencing, Programming, Gaming, Bowling, Reading"
	_temp2.image = LoadImage("images/profiles/tc.jpg")
	_temp2.attending.insert(eventLists[0])
	_temp2.attending.insert(eventLists[1])
	profileList.insert(_temp2)
	
	
	_temp2.ID = 2
	_temp2.name = "Ryan Hill"
	_temp2.gender = "Male"
	_temp2.age = 20
	_temp2.hobbies = "Sports, Biking, Eating"
	_temp2.image = LoadImage("images/profiles/rh.jpg")
	profileList.insert(_temp2)
	
	_temp2.ID = 3
	_temp2.name = "Andrea Kao"
	_temp2.gender = "Female"
	_temp2.age = 21
	_temp2.hobbies = "Messing with Eileen"
	_temp2.image = LoadImage("images/profiles/ak.jpg")
	profileList.insert(_temp2)
	
	_temp2.ID = 4
	_temp2.name = "Eileen Cho"
	_temp2.gender = "Female"
	_temp2.age = 21
	_temp2.hobbies = "Messing with Andrea"
	_temp2.image = LoadImage("images/profiles/ec.jpg")
	profileList.insert(_temp2)
	
	_temp2.ID = 5
	_temp2.name = "Shue-Li Rosen"
	_temp2.gender = "Female"
	_temp2.age = 21
	_temp2.hobbies = "Shue-li stuff"
	_temp2.image = LoadImage("images/profiles/sr.jpg")
	profileList.insert(_temp2)
	
	_temp2.ID = 6
	_temp2.name = "Kathy Huynh"
	_temp2.gender = "Female"
	_temp2.age = 21
	_temp2.hobbies = "Kathy stuff"
	_temp2.image = LoadImage("images/profiles/kh.jpg")
	profileList.insert(_temp2)
	
	SetSpriteVisible(nav_profile , 1)
	SetSpriteVisible(nav_home , 1)
	SetSpriteVisible(nav_search , 1)
	SetSpriteVisible(nav_create , 1)
	SetSpriteDepth(nav_profile, 1)
	SetSpriteDepth(nav_home, 1)
	SetSpriteDepth(nav_create, 1)
	SetSpriteDepth(nav_search, 1)
	
endfunction
Function ResetProfile()
	SetSpriteVisible(p_background, 1)
	SetSpriteVisible(p_image_sprite, 1)
	SetTextVisible(p_name, 1)
	SetTextVisible(p_sex_age, 1)
	SetTextVisible(p_hobbies, 1)
endfunction
Function LoadProfileScreen()
	if p_created = 0
		temp = LoadImage("images/bg-profile.png")
		Global p_background = 0
		Global p_name = 0
		Global p_sex_age = 0
		Global p_hobbies = 0
		Global p_image_sprite = 0
		expand_offset = 0
		
		p_background = CreateSprite(temp)
		temp = profileList[sessionID-1].image
		p_image_sprite = CreateSprite(temp)
		SetSpriteDepth(p_background, 8)
		SetSpriteDepth(p_image_sprite, 7)
		SetSpritePosition(p_image_sprite, 745, 220)
		
		p_name = CreateText(profileList[sessionID-1].name)
		_temp$ = profileList[sessionID-1].gender + ", " + str(profileList[sessionID-1].age)
		p_sex_age = CreateText(_temp$)
		_temp$ = "Likes: " + profileList[sessionID-1].hobbies
		p_hobbies = CreateText(_temp$)
		SetTextDepth(p_name, 7)
		SetTextDepth(p_sex_age, 7)
		SetTextDepth(p_hobbies, 7)
		SetTextSize(p_name, 100)
		SetTextSize(p_hobbies, 50)
		SetTextSize(p_sex_age, 50)
		SetTextMaxWidth(p_hobbies, 795)
		SetTextPosition(p_name, 87, 280)
		SetTextPosition(p_hobbies, 95, 470)
		SetTextPosition(p_sex_age, 95, 400)
		SetTextColor(p_name, 242,107,88,255)
		SetTextColor(p_hobbies, 0,0,0,255)
		SetTextColor(p_sex_age, 0,0,0,255)
		p_created = 1
	else
		ResetProfile()
	endif
endfunction
Function ProfileScreenLoop()
	if short_cardList.length = -1
		if p_tab = 0
			if profileList[sessionID-1].hosting.length > -1
				for i=0 to profileList[sessionID-1].hosting.length
					CreateShortCard(profileList[sessionID-1].hosting[i], 240*i)
				next i
			endif
		elseif p_tab = 1
			if profileList[sessionID-1].attending.length > -1
				for i=0 to profileList[sessionID-1].attending.length
					CreateShortCard(profileList[sessionID-1].attending[i], 240*i)
				next i
			endif
		elseif p_tab = 2
			if profileList[sessionID-1].bookmarked.length > -1
				for i=0 to profileList[sessionID-1].bookmarked.length
					CreateShortCard(profileList[sessionID-1].bookmarked[i], 240*i)
				next i
			endif
		elseif p_tab = 3
			if profileList[sessionID-1].history.length > -1
				for i=0 to profileList[sessionID-1].history.length
					CreateShortCard(profileList[sessionID-1].history[i], 240*i)
				next i
			endif
		endif
	endif
	if short_cardList.length > -1
		updateShortCards()
	endif
	if GetPointerPressed() = 1
		_x = ScreenToWorldX(GetPointerX())
		_y = ScreenToWorldY(GetPointerY())
		
		if GetSpriteHitTest(nav_home ,_x,_y)
			SetSpriteVisible(p_image_sprite, 0)
			SetSpriteVisible(p_background, 0)
			SetTextVisible( p_name, 0)
			SetTextVisible( p_hobbies, 0)
			SetTextVisible( p_sex_age, 0)
			screen_state = 0
			temp = LoadImage("images/nav_home_A.png")
			SetSpriteImage(nav_home, temp)
			temp = LoadImage("images/nav_profile.png")
			SetSpriteImage(nav_profile, temp)
			Sync()
		elseif GetSpriteHitTest(nav_create ,_x,_y)
			SetSpriteVisible(p_image_sprite, 0)
			SetSpriteVisible(p_background, 0)
			SetTextVisible( p_name, 0)
			SetTextVisible( p_hobbies, 0)
			SetTextVisible( p_sex_age, 0)
			screen_state = 3
			temp = LoadImage("images/nav_profile.png")
			SetSpriteImage(nav_profile, temp)
			temp = LoadImage("images/nav_create_A.png")
			SetSpriteImage(nav_create, temp)
			LoadCreateScreenGlobals()
			Sync()
		elseif GetSpriteHitTest(nav_search ,_x,_y)
			
		endif
	endif
	Sync()
endfunction
Function LoadCreateScreenGlobals() 
	if c_created = 1
		ResetCreate()
	else
		temp = LoadImage("images/bg-create.png")
		Global c_background = 0
		Global c_in_title = 0
		Global c_in_date = 0
		Global c_in_time = 0
		Global c_in_loc = 0
		Global c_in_desc = 0
		Global c_in_curNum = 0
		Global c_in_maxNum = 0
		Global c_in_tags = 0
		c_background = CreateSprite(temp)
		SetSpriteDepth(c_background, 8)
		c_in_title = CreateText("Event Name")
		c_in_date = CreateText("Date")
		c_in_time = CreateText("Start Time")
		c_in_loc = CreateText("Location Address")
		c_in_desc = CreateText("Event Description (440 char max)")
		c_in_curNum = CreateText("1")
		c_in_maxNum = CreateText("2")
		c_in_tags = CreateText("Tags (separate with comma)")
		SetTextDepth(c_in_title, 7)
		SetTextDepth(c_in_date, 7)
		SetTextDepth(c_in_time, 7)
		SetTextDepth(c_in_loc, 7)
		SetTextDepth(c_in_desc, 7)
		SetTextDepth(c_in_curNum, 7)
		SetTextDepth(c_in_maxNum, 7)
		SetTextDepth(c_in_tags, 7)
		SetTextSize(c_in_title, 35)
		SetTextSize(c_in_date, 35)
		SetTextSize(c_in_time, 35)
		SetTextSize(c_in_loc, 35)
		SetTextSize(c_in_desc, 25)
		SetTextSize(c_in_curNum, 35)
		SetTextSize(c_in_maxNum, 35)
		SetTextSize(c_in_tags, 35)
		SetTextMaxWidth(c_in_desc, 870)
		SetTextPosition(c_in_title, 90, 760)
		SetTextPosition(c_in_date, 90, 865)
		SetTextPosition(c_in_time, 90, 964)
		SetTextPosition(c_in_loc, 90, 1060)
		SetTextPosition(c_in_desc, 108, 1215)
		SetTextPosition(c_in_curNum, 120, 1920-405)
		SetTextPosition(c_in_maxNum, 120, 1920-300)
		SetTextPosition(c_in_tags, 90, 1730)
		SetTextColor(c_in_title, 0,0,0,255)
		SetTextColor(c_in_date, 0,0,0,255)
		SetTextColor(c_in_time, 0,0,0,255)
		SetTextColor(c_in_loc, 0,0,0,255)
		SetTextColor(c_in_desc, 0,0,0,255)
		SetTextColor(c_in_curNum, 0,0,0,255)
		SetTextColor(c_in_maxNum, 0,0,0,255)
		SetTextColor(c_in_tags, 0,0,0,255)
		c_created = 1
	endif
endfunction
Function ResetCreate()
	SetSpriteVisible( c_background, 1)
	SetTextVisible( c_in_title, 1)
	SetTextVisible( c_in_date, 1)
	SetTextVisible( c_in_time, 1)
	SetTextVisible( c_in_loc, 1)
	SetTextVisible( c_in_desc, 1)
	SetTextVisible( c_in_curNum, 1)
	SetTextVisible( c_in_maxNum, 1)
	SetTextVisible( c_in_tags, 1)
	SetTextString(c_in_title, "Event Name")
	SetTextString(c_in_date, "Date")
	SetTextString(c_in_time, "Start Time")
	SetTextString(c_in_loc, "Location Address")
	SetTextString(c_in_desc, "Event Description (440 char max)")
	SetTextString(c_in_curNum, "1")
	SetTextString(c_in_maxNum, "2")
	SetTextString(c_in_tags, "Tags (separate with comma)")
endfunction
Function CreateScreenLoop()
	if GetPointerPressed() = 1
		_x = ScreenToWorldX(GetPointerX())
		_y = ScreenToWorldY(GetPointerY())
		
		if GetSpriteHitTest(nav_profile ,_x,_y)
			SetSpriteVisible(c_background, 0)
			SetTextVisible( c_in_title, 0)
			SetTextVisible( c_in_date, 0)
			SetTextVisible( c_in_time, 0)
			SetTextVisible( c_in_desc, 0)
			SetTextVisible( c_in_loc, 0)
			SetTextVisible( c_in_curNum, 0)
			SetTextVisible( c_in_maxNum, 0)
			SetTextVisible( c_in_tags, 0)
			screen_state = 2
			temp = LoadImage("images/nav_profile_A.png")
			SetSpriteImage(nav_profile, temp)
			temp = LoadImage("images/nav_create.png")
			SetSpriteImage(nav_create, temp)
			LoadProfileScreen()
			Sync()
		elseif GetSpriteHitTest(nav_home ,_x,_y)
			SetSpriteVisible(c_background, 0)
			SetTextVisible( c_in_title, 0)
			SetTextVisible( c_in_date, 0)
			SetTextVisible( c_in_time, 0)
			SetTextVisible( c_in_desc, 0)
			SetTextVisible( c_in_loc, 0)
			SetTextVisible( c_in_curNum, 0)
			SetTextVisible( c_in_maxNum, 0)
			SetTextVisible( c_in_tags, 0)
			screen_state = 0
			temp = LoadImage("images/nav_home_A.png")
			SetSpriteImage(nav_home, temp)
			temp = LoadImage("images/nav_create.png")
			SetSpriteImage(nav_create, temp)
			Sync()
		elseif GetSpriteHitTest(nav_search ,_x,_y)
			
		endif
		
		if _x > 90 and _x < 990
			if _y > 750 and _y < 795
				SetTextString(c_in_title, Input("", 30))
				SetTextVisible(c_in_title, 1)
				if not GetTextString(c_in_title) = ""
					title$ = GetTextString(c_in_title)
				endif
				Sync()
			elseif _y > 855 and _y < 900
				SetTextString(c_in_date, Input("", 30))
				SetTextVisible(c_in_date, 1)
				Sync()
			elseif _y > 955 and _y < 1000 and _x < 370
				SetTextString(c_in_time, Input("", 30))
				SetTextVisible(c_in_time, 1)
				Sync()
			elseif _y > 1060 and _y < 1105
				SetTextString(c_in_loc, Input("", 30))
				SetTextVisible(c_in_loc, 1)
				Sync()
			elseif _y > 1190 and _y < 1465
				SetTextString(c_in_desc, Input("", 440))
				SetTextVisible(c_in_desc, 1)
				Sync()
			elseif _y > 1490 and _y < 1560 and _x < 207
				SetTextString(c_in_curNum, Input("", 2))
				SetTextVisible(c_in_curNum, 1)
				Sync()
			elseif _y > 1590 and _y < 1660 and _x < 207
				SetTextString(c_in_maxNum, Input("", 2))
				SetTextVisible(c_in_maxNum, 1)
				Sync()
			elseif _y > 1710 and _y < 1760
				SetTextString(c_in_tags, Input("", 80))
				SetTextVisible(c_in_tags, 1)
				Sync()
			endif
			if _x > 580 and _x < 840 and _y > 1805 and _y < 1885
				CreateEvent(GetTextString(c_in_title), GetTextString(c_in_date), GetTextString(c_in_time), GetTextString(c_in_loc), GetTextString(c_in_desc), val(GetTextString(c_in_curNum)), val(GetTextString(c_in_maxNum)), GetTextString(c_in_tags))
				snap(-1)
				snap(1)
				SetSpriteVisible(c_background, 0)
				SetTextVisible( c_in_title, 0)
				SetTextVisible( c_in_date, 0)
				SetTextVisible( c_in_time, 0)
				SetTextVisible( c_in_desc, 0)
				SetTextVisible( c_in_loc, 0)
				SetTextVisible( c_in_curNum, 0)
				SetTextVisible( c_in_maxNum, 0)
				SetTextVisible( c_in_tags, 0)
				screen_state = 0
				temp = LoadImage("images/nav_home_A.png")
				SetSpriteImage(nav_home, temp)
				temp2 = LoadImage("images/nav_create.png")
				SetSpriteImage(nav_create, temp2)
				Sync()
			endif
		endif
	endif
	Sync()
endfunction
Function LoadCard(c ref as card, e as eventVar, offset as integer)
	attendee$ = str(e.cur_n) + "/" + str(e.max_n) + " Attending"
	if GetMinutesFromUnix(e.date) < 10
		min$ = str(0)+str(GetMinutesFromUnix(e.date))
	else
		min$ = str(GetMinutesFromUnix(e.date))
	endif
	time$ = str(GetHoursFromUnix(e.date)) + ":" + min$ + ", " + str(GetMonthFromUnix(e.date)) + "/" + str(GetDaysFromUnix(e.date))
	SetTextString(c.title, e.title)
	SetTextString(c.loc, e.location)
	SetTextString(c.date, time$)
	SetTextString(c.num_attend, attendee$)
	SetTextString(c.desc, e.desc)
	SetSpriteImage(c.image, e.image)
	SetSpriteSize(c.image, 890, 645)
	c.eventID = e.ID
	c.offset = offset

	sync()
endfunction
Function CreateShortCard(e as eventVar, offset as integer)
	c as short_card
	if GetMinutesFromUnix(e.date) < 10
		min$ = str(0)+str(GetMinutesFromUnix(e.date))
	else
		min$ = str(GetMinutesFromUnix(e.date))
	endif
	time$ = str(GetHoursFromUnix(e.date)) + ":" + min$ + ", " + str(GetMonthFromUnix(e.date)) + "/" + str(GetDaysFromUnix(e.date))
	c.sprite = CreateSprite(LoadImage("images/short_card_bg.png"))	
	c.title = CreateText("")
	c.loc = CreateText("")
	c.date = CreateText("")
	SetSpriteSize(c.sprite, 1080, 240)
	SetSpriteDepth(c.sprite, 7)
	SetTextDepth(c.title, 6)
	SetTextDepth(c.date, 6)
	SetTextDepth(c.loc, 6)
	SetTextSize(c.title, 40)
	SetTextSize(c.date, 35)
	SetTextSize(c.loc, 33)
	SetTextColor(c.title, 242,101,81,255)
	SetTextColor(c.date, 0,0,0,255)
	SetTextColor(c.loc, 0,0,0,255)
	SetTextMaxWidth(c.title,820)
	SetTextMaxWidth(c.date,820)
	SetTextMaxWidth(c.loc,820)
	
	SetTextString(c.title, e.title)
	SetTextString(c.loc, e.location)
	SetTextString(c.date, time$)
	c.offset = offset
	c.eventID = e.ID

	if mod(offset/240, 2) = 1
		SetSpriteColor(c.sprite, 235,235,235,255)
	endif
	
	short_cardList.insert(c)
endfunction
Function updateCards()
	if Screen_state = 0
		for i=0 to 2
			SetSpritePosition(cardList[i].sprite, cardList[i].offset-card_offset, 260)
			SetSpritePosition(cardList[i].image, GetSpriteX(cardList[i].sprite)+5, GetSpriteY(cardList[i].sprite)+5)
			SetTextPosition(cardList[i].title, GetSpriteX(cardList[i].sprite)+50, GetSpriteY(cardList[i].sprite)+660)
			SetTextPosition(cardList[i].date, GetSpriteX(cardList[i].sprite)+50, GetSpriteY(cardList[i].sprite)+820)
			SetTextPosition(cardList[i].desc, GetSpriteX(cardList[i].sprite)+50, GetSpriteY(cardList[i].sprite)+860)
			SetTextPosition(cardList[i].loc, GetSpriteX(cardList[i].sprite)+50, GetSpriteY(cardList[i].sprite)+780)
			SetTextPosition(cardList[i].num_attend, GetSpriteX(cardList[i].sprite)+282, GetSpriteY(cardList[i].sprite)+1220)
		next i
	elseif Screen_state = 1
		for i=0 to 2
			if cardList[i].selected = 1
				SetSpritePosition(cardList[i].sprite, 0, 120+expand_offset)
				SetSpritePosition(cardList[i].image, 0, GetSpriteY(cardList[i].sprite))
				SetTextPosition(cardList[i].title, 50, GetSpriteY(cardList[i].sprite)+1135)
				SetTextPosition(cardList[i].date, 50, GetTextY(cardList[i].loc)+GetTextTotalHeight(cardList[i].loc))
				SetTextPosition(cardList[i].desc, 50, GetTextY(cardList[i].date)+GetTextTotalHeight(cardList[i].date) + 20)
				SetTextPosition(cardList[i].loc, 50, GetTextY(cardList[i].title)+GetTextTotalHeight(cardList[i].title))
				SetTextPosition(cardList[i].num_attend, 50, GetTextY(cardList[i].desc)+GetTextTotalHeight(cardList[i].desc))
			endif
		next i
	endif
	Sync()
endfunction
Function updateShortCards()
	for i=0 to short_cardList.length
		SetSpritePosition(short_cardList[i].sprite, 0, 780+expand_offset+short_cardList[i].offset)
		SetTextPosition(short_cardList[i].title, 60, 820+expand_offset+short_cardList[i].offset)
		SetTextPosition(short_cardList[i].date, 60, 890+expand_offset+short_cardList[i].offset)
		SetTextPosition(short_cardList[i].loc, 60, 955+expand_offset+short_cardList[i].offset)
	next i
endfunction
Function snap(d as integer)
	counter = 0
	do
		if counter < 38
			if d>0
				card_offset = card_offset+25
				if counter = 19 and current_c_index <= eventLists.length-1 and current_c_index > 1
					_i = mod(current_c_index+1, 3)
					_o = cardList[mod(current_c_index,3)].offset
					LoadCard(cardList[_i], eventLists[current_c_index+1], _o+950)
				endif
			else
				card_offset = card_offset-25
				if counter = 19 and current_c_index >= 1 and current_c_index < eventLists.length-1
					_i = mod(current_c_index-1, 3)
					_o = cardList[mod(current_c_index,3)].offset
					LoadCard(cardList[_i], eventLists[current_c_index-1], _o-950)
				endif
			endif
			updateCards()
			counter = counter + 1
		else
			exit
		endif
	loop
	transition = 0
endfunction
Function collapseCard(c ref as card)
	c.selected = 0
	SetSpriteVisible(c.sprite, 1)
	SetSpritePosition(c.sprite, -5,115)
	counter = 0
	transX = (c.offset-card_offset)/20
	transY = (260-GetSpriteY(c.sprite))/20
	transSizeX = (GetSpriteWidth(c.sprite)-900)/20
	transSizeY = (GetSpriteHeight(c.sprite)-1325)/20
	transISizeX = 180/20
	transISizeY = (1100-645)/20
	do
		if counter > 20
			exit
		endif
		SetSpritePosition(c.sprite, getSpriteX(c.sprite)+transX, GetSpriteY(c.sprite)+transY)
		SetSpriteSize(c.sprite, GetSpriteWidth(c.sprite)-transSizeX, GetSpriteHeight(c.sprite)-transSizeY)
		SetSpritePosition(c.image, getSpriteX(c.sprite)+transX+5, GetSpriteY(c.sprite)+transY-10)
		SetSpriteSize(c.image, GetSpriteWidth(c.image)-transISizeX, GetSpriteHeight(c.image)-transISizeY)
		
		if counter < 6
			SetTextColorAlpha(c.title, GetTextColorAlpha(c.title)-255/6)
			SetTextColorAlpha(c.date, GetTextColorAlpha(c.date)-255/6)
			SetTextColorAlpha(c.desc, GetTextColorAlpha(c.desc)-255/6)
			SetTextColorAlpha(c.loc, GetTextColorAlpha(c.loc)-255/6)
			SetTextColorAlpha(c.num_attend, GetTextColorAlpha(c.num_attend)-255/6)
		elseif counter < 14
			SetSpritePosition(c.image, GetSpriteX(c.sprite)+5, GetSpriteY(c.sprite)+5)
			SetTextPosition(c.title, GetSpriteX(c.sprite)+50, GetSpriteY(c.sprite)+660)
			SetTextPosition(c.date, GetSpriteX(c.sprite)+50, GetSpriteY(c.sprite)+820)
			SetTextPosition(c.desc, GetSpriteX(c.sprite)+50, GetSpriteY(c.sprite)+860)
			SetTextPosition(c.loc, GetSpriteX(c.sprite)+50, GetSpriteY(c.sprite)+780)
			SetTextPosition(c.num_attend, GetSpriteX(c.sprite)+282, GetSpriteY(c.sprite)+1220)
			SetTextMaxWidth(c.title, 800)
			SetTextSize(c.title, 60)
			SetTextMaxWidth(c.date, 800)
			SetTextSize(c.date, 30)
			SetTextMaxWidth(c.desc, 800)
			SetTextSize(c.desc, 30)
			SetTextMaxWidth(c.loc, 800)
			SetTextSize(c.loc, 30)
			SetTextMaxWidth(c.num_attend, 800)
			SetTextSize(c.num_attend, 45)
		else
			SetTextColorAlpha(c.title, GetTextColorAlpha(c.title)+255/5)
			SetTextColorAlpha(c.date, GetTextColorAlpha(c.date)+255/5)
			SetTextColorAlpha(c.desc, GetTextColorAlpha(c.desc)+255/5)
			SetTextColorAlpha(c.loc, GetTextColorAlpha(c.loc)+255/5)
			SetTextColorAlpha(c.num_attend, GetTextColorAlpha(c.num_attend)+255/5)
		endif
		counter = counter + 1
		sync()
	loop
	expand_offset = 0
	SetSpritePosition(c.sprite, (c.offset-card_offset), 260)
	SetSpritePosition(c.image, GetSpriteX(c.sprite)+5, GetSpriteY(c.sprite)+5)
	SetSpriteSize(c.sprite, 900, 1325)
	SetSpriteSize(c.image, 890, 645)
	
	for i=0 to 2
		SetSpriteVisible(cardList[i].sprite, 1)
		SetSpriteVisible(cardList[i].image, 1)
	next i
	
endfunction
Function expandCard(c ref as card)
	counter = 0
	transX = GetSpriteX(c.sprite)/20
	transY = 140/20
	transSizeX = 180/20
	transSizeY = 595/20
	transISizeX = 170/20
	transISizeY = 460/20
	do
		if counter > 20
			exit
		endif
		SetSpritePosition(c.sprite, getSpriteX(c.sprite)-transX, GetSpriteY(c.sprite)-transY)
		SetSpriteSize(c.sprite, GetSpriteWidth(c.sprite)+transSizeX, GetSpriteHeight(c.sprite)+transSizeY)
		SetSpritePosition(c.image, getSpriteX(c.sprite)-transX+5, GetSpriteY(c.sprite)-transY+10)
		SetSpriteSize(c.image, GetSpriteWidth(c.image)+transISizeX, GetSpriteHeight(c.image)+transISizeY)
		
		if counter < 6
			SetTextColorAlpha(c.title, GetTextColorAlpha(c.title)-255/6)
			SetTextColorAlpha(c.date, GetTextColorAlpha(c.date)-255/6)
			SetTextColorAlpha(c.desc, GetTextColorAlpha(c.desc)-255/6)
			SetTextColorAlpha(c.loc, GetTextColorAlpha(c.loc)-255/6)
			SetTextColorAlpha(c.num_attend, GetTextColorAlpha(c.num_attend)-255/6)
		elseif counter < 14
			SetTextPosition(c.title, 50, GetSpriteY(c.sprite)+1135)
			SetTextMaxWidth(c.title, 980)
			SetTextSize(c.title, 75)
			SetTextPosition(c.date, 50, GetSpriteY(c.sprite)+1335)
			SetTextMaxWidth(c.date, 980)
			SetTextSize(c.date, 40)
			SetTextPosition(c.desc, 50, GetSpriteY(c.sprite)+1400)
			SetTextMaxWidth(c.desc, 980)
			SetTextSize(c.desc, 55)
			SetTextPosition(c.loc, 50, GetSpriteY(c.sprite)+1290)
			SetTextMaxWidth(c.loc, 980)
			SetTextSize(c.loc, 40)
			SetTextPosition(c.num_attend, 50, GetSpriteY(c.sprite)+2000)
			SetTextMaxWidth(c.num_attend, 980)
			SetTextSize(c.num_attend, 60)
		else
			SetTextColorAlpha(c.title, GetTextColorAlpha(c.title)+255/5)
			SetTextColorAlpha(c.date, GetTextColorAlpha(c.date)+255/5)
			SetTextColorAlpha(c.desc, GetTextColorAlpha(c.desc)+255/5)
			SetTextColorAlpha(c.loc, GetTextColorAlpha(c.loc)+255/5)
			SetTextColorAlpha(c.num_attend, GetTextColorAlpha(c.num_attend)+255/5)
		endif
		counter = counter + 1
		sync()
	loop
	expand_offset = 0
	SetSpritePosition(c.sprite, -5, 115)
	SetSpritePosition(c.image, 0, 120)
	SetSpriteSize(c.sprite, 1090, 1810)
	SetSpriteSize(c.image, 1080, 1100)
	SetSpriteVisible(c.sprite, 0)
	c.selected = 1
	
	for i=0 to 2
		if cardList[i].selected = 0
			SetSpriteVisible(cardList[i].sprite, 0)
			SetSpriteVisible(cardList[i].image, 0)
		endif
	next i
	
endfunction
Function CreateEvent(t as String, d as String, time as String, loc as String, desc as String, cn as integer, mn as integer, tags as string)
	_temp as eventVar
	_temp.title = t
	_temp.ID = eventLists.length+1
	_temp.cur_n = cn
	_temp.max_n = mn
	_temp.date = GetUnixFromDate(2015,12,20,18,0,0)
	_temp.desc = desc
	_temp.hostID = sessionID
	_temp.image = LoadImage("images/bowling.png")
	_temp.location = loc
	eventLists.insert(_temp)
endfunction

Function Input(textin$,length)

    SetCursorBlinkTime(0.5)
    SetTextInputMaxChars(length)
    StartTextInput(textin$)

    do
        sync()
        state=GetTextInputState()
        c=GetLastChar()
        if GetTextInputCompleted()
            if GetTextInputCancelled()
                text$=textin$
                exit
            else
                text$=GetTextInput()
                exit
            endif
        endif

    loop

    StopTextInput()
    sync()

endfunction text$
