return {
    name = "Level 1 - Neon Torii Approach",
    width = 3584,
    height = 768,
    start = {x=80, y=564},
    goal = {x=3460, y=556, w=90, h=150},
    platforms = {
        {x=0,y=704,w=420,h=40}, {x=540,y=704,w=520,h=40}, {x=1180,y=704,w=360,h=40},
        {x=1690,y=704,w=560,h=40}, {x=2420,y=704,w=420,h=40}, {x=3000,y=704,w=584,h=40},
        {x=260,y=614,w=130,h=18}, {x=620,y=624,w=150,h=18}, {x=860,y=564,w=130,h=18},
        {x=1230,y=614,w=110,h=18}, {x=1400,y=539,w=150,h=18}, {x=1780,y=624,w=160,h=18},
        {x=2070,y=559,w=120,h=18}, {x=2500,y=609,w=150,h=18}, {x=2780,y=544,w=160,h=18},
        {x=3180,y=614,w=150,h=18}
    },
    movingPlatforms = {
        {x=1090,y=634,w=90,h=16, dx=180, dy=0, speed=55},
        {x=2280,y=594,w=100,h=16, dx=0, dy=-110, speed=45},
        {x=2890,y=624,w=90,h=16, dx=170, dy=0, speed=65}
    },
    enemies = {
        {kind="blue", x=650, y=654}, {kind="red", x=930, y=659}, {kind="yellow", x=1320, y=454},
        {kind="blue", x=1830, y=654}, {kind="red", x=2130, y=514}, {kind="yellow", x=2580, y=464},
        {kind="blue", x=3090, y=654}, {kind="red", x=3290, y=659}
    },
    decorations = {
        {kind="torii", x=150, y=584}, {kind="antenna", x=720, y=614}, {kind="lantern", x=1510, y=504},
        {kind="gate", x=3450, y=554}, {kind="moon", x=760, y=110}
    }
}
