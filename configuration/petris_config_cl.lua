Petris_ClientConfig = {
    ["DropOff"] = {
        ["Ped"] = "cs_martinmadrazo", -- Must be the same with server sided, in order to load & work. 
        ["MarkerCoords"] = {x = 1391.78, y = 1141.52, z = 113.44, heading = 273.0}
    },
    ["BriefcaseProp"] = "prop_security_case_01",
    ["BlipSettings"] = {
        ["Area"] = {
            Name = "Briefcase Area",
            Sprite = 456, 
            Scale = 1.0,
            Color = 5,
            RadiusAlpha = 100
        },
        ["Briefcase"] = {
            Name = "Briefcase",
            Sprite = 440, 
            Scale = 0.8, 
            Color = 2
        },
        ["Holder"] = {
            Name = "Briefcase Holder",
            Sprite = 586, 
            Scale = 1.0,
            Color = 1
        },
        ["DropOff"] = {
            Name = "Briefcase Drop Off",
            Scale = 1.0, 
        }
    },
    ["Animation"] = {
        Dictionary = "anim@heists@narcotics@trash",
        Name = "pickup"
    },
    ["MissionText"] = "Deliver the ~b~briefcase ~w~to the ~y~drop off.",
    ["Notifications"] = {
        HelpNotification = "Press ~INPUT_CONTEXT~ to pick up the ~g~briefcase",   
        DropoffHelpNotification = "Press ~INPUT_CONTEXT~ to ~y~deliver ~w~the ~g~briefcase",
        ["EventFailure"] = '~r~Error: ~w~The server was unable to send you some event data. ~n~Please re-log into the server to be able to part.'
    },
    ["Scaleform"] = {
        WinnerHeader = '~g~mission passed',
        WinnerText = 'You successfully delivered the briefcase to Martin'
    },
    ["Messages"] = {
        Title = "Martin",
        Subject = "Briefcase Mission",
        Icon = "CHAR_MARTIN", -- https://wiki.gtanet.work/index.php?title=Notification_Pictures
        IconType = 1,
        ["StartMessage"] = "A well-known hacker publicly exposed SecuroServ's briefcase location. Bring it to me!",
        ["FailureMessage"] = 'Bad news for you! Someone else delivered the briefcase faster.',
        ["Expired"] = 'Time\'s UP! SecuroServ collected and protected the briefcase.'
    },
    ["Events"] = {
        PlayerLoaded = "esx:playerLoaded" -- add your client event name which defines player's load into the server.
    }
}