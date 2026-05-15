return {
    name = "Level 1 - Neon Torii Approach",
    width = 3584,
    height = 540,
    start = {x=80, y=360},
    goal = {x=3460, y=352, w=90, h=150},
    platforms = {
        {x=0,y=500,w=420,h=40}, {x=540,y=500,w=520,h=40}, {x=1180,y=500,w=360,h=40},
        {x=1690,y=500,w=560,h=40}, {x=2420,y=500,w=420,h=40}, {x=3000,y=500,w=584,h=40},
        {x=260,y=410,w=130,h=18}, {x=620,y=420,w=150,h=18}, {x=860,y=360,w=130,h=18},
        {x=1230,y=410,w=110,h=18}, {x=1400,y=335,w=150,h=18}, {x=1780,y=420,w=160,h=18},
        {x=2070,y=355,w=120,h=18}, {x=2500,y=405,w=150,h=18}, {x=2780,y=340,w=160,h=18},
        {x=3180,y=410,w=150,h=18}
    },
    movingPlatforms = {
        {x=1090,y=430,w=90,h=16, dx=180, dy=0, speed=55},
        {x=2280,y=390,w=100,h=16, dx=0, dy=-110, speed=45},
        {x=2890,y=420,w=90,h=16, dx=170, dy=0, speed=65}
    },
    enemies = {
        {kind="blue", x=650, y=450}, {kind="red", x=930, y=455}, {kind="yellow", x=1320, y=250},
        {kind="blue", x=1830, y=450}, {kind="red", x=2130, y=310}, {kind="yellow", x=2580, y=260},
        {kind="blue", x=3090, y=450}, {kind="red", x=3290, y=455}
    },
    decorations = {
        {kind="torii", x=150, y=380}, {kind="antenna", x=720, y=410}, {kind="lantern", x=1510, y=300},
        {kind="gate", x=3450, y=350}, {kind="moon", x=700, y=70}
    }
}
