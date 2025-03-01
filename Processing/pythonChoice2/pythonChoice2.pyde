
score = 0

class Button:
    value = False
    offtxt = "budton of f :("
    ontxt = "BUTTON"
    xv = 0.0
    yv = 0.0
    
    startw = 0.0
    starth = 0.0
    
    spoo = 0.0
    
    def __init__(self, x, y, w, h):
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.startw = w
        self.starth = h
        self.spoo = random(TWO_PI)
        
    def render(self):
       global score
       k = -1.0
       if self.value:
           self.w += 0.5
           self.h += 0.5
           k = 1.0
           score += 1.0
       if dist(mouseX, mouseY, self.x + self.h/2.0, self.y + self.w/2.0) < 200.0:
           self.xv += 0.1*(mouseX-(self.x + self.w/2.0))*k
           self.yv += 0.1*(mouseY-(self.y + self.h/2.0))*k
       self.x += self.xv
       self.y += self.yv
       self.yv /= 1.1
       self.xv /= 1.1
       if self.x < 0.0:
           self.xv *= -1.0
           self.x += 10.0
       if self.x + self.w > width:
           self.xv *= -1.0
           self.x -= 10.0
       if self.y < 0.0:
           self.yv *= -1.0
           self.y += 10.0
       if self.y + self.h > width:
           self.yv *= -1.0
           self.y -= 10.0
       stroke(200, 200, 255)
       if self.value:
           #fill(100, 100, 150, 100)
           fill(random(255), random(255), random(255), 100)
       else:
           fill(10, 10, 50, 100)
       rect(self.x, self.y, self.w, self.h)
       if self.value:
           fill(10, 10, 50)
       else:
           fill(100, 100, 150)
       textAlign(CENTER, CENTER)
       txt = self.offtxt
       if self.value:
           txt = self.ontxt
           self.w += sin(frameCount/10.1 + self.spoo)*3.0
           self.h += cos(frameCount/10.1 + self.spoo)/2.0
       text(txt, self.x + self.w/2.0, self.y + self.h/2.0)
              
    def check_mouse(self):
        if mouseX > self.x and mouseX < self.x + self.w and mouseY > self.y and mouseY < self.y + self.h:
            self.value = not self.value
            if not self.value:
                self.w = self.startw
                self.h = self.starth
            
booton = []

def setup():
    size(800, 800)
    textSize(24)
    global booton
    booton = [Button(random(width), random(height), 200 + random(-50, 50), 60 + random(-10, 10)) for x in range(0, 100)]
    hint(DISABLE_DEPTH_TEST)

def draw():
    global score
    score = 0.0
    background(0)
    for b in booton:
        b.render()
    
    fill(255, 255, 255, 255)
    textAlign(LEFT, TOP)
    text("Score: " + str(score), 10, 10)

def mousePressed():
    for b in booton:
        b.check_mouse()