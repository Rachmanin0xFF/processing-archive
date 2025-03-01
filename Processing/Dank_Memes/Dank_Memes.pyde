class Button:
    state = False
    pmouse = False

    def __init__(self, x, y, w, h, label="", toggle=True):
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.label = label
        self.toggle = toggle

    def render(self):
        if self.x < mouseX and mouseX < self.x + self.w and self.y < mouseY and mouseY < self.y + self.h:
            strokeWeight(3)
            # Toggle button when the mouse is pressed, and wasn't pressed
            if self.toggle:
                if self.pmouse is False and mousePressed is True:
                    self.state = not self.state
            else:
                self.state = mousePressed
        # If the mouse is not on the button, and toggle isn't on, turn button
        # off
        elif not self.toggle:
            strokeWeight(2)
            self.state = False
        # if the mouse isn't pressed, turn it off
        if self.toggle is False and not mousePressed:
            self.state = False

        self.pmouse = mousePressed

        if self.state:
            fill(180, 200)
        else:
            fill(80, 200)
        stroke(200)
        rect(self.x, self.y, self.w, self.h)

        fill(255)
        textAlign(CENTER, CENTER)
        textSize(20)
        if self.label is not "":
            text(self.label+": "+("ON" if self.state else "OFF"), self.x + self.w / 2, self.y + self.h / 2)
        else:
            text("ON" if self.state else "OFF", self.x + self.w / 2, self.y + self.h / 2)
         
class Slider:
    state = 0.0

    def __init__(self, x, y, w, h, label=""):
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.label = label

    def render(self):
        strokeWeight(2)
        if self.x < mouseX and mouseX < self.x + self.w and self.y < mouseY and mouseY < self.y + self.h:
            strokeWeight(3)
            if mousePressed:
                self.state = max(
                    0, min(1, map(mouseX - self.x, self.h / 2.0, self.w - self.h/2.0, 0.0, 1.0)))
        

        fill(80, 200)
        stroke(200)
        rect(self.x, self.y, self.w, self.h)
        if mousePressed and self.x < mouseX and mouseX < self.x + self.w and self.y < mouseY and mouseY < self.y + self.h:
            fill(180, 200)
        rect(self.x + (self.w - self.h) * self.state, self.y, self.h, self.h)

        fill(255)
        textAlign(CENTER, CENTER)
        textSize(20)
        text(self.label+": "+nf(self.state,1,3), self.x + self.w / 2, self.y + self.h / 2)

##########_(_###############################################_(_#############
#########/o~o\############ HERE WE CODE THE CODES #########/o~o\############
########< xxx >###########   RIGHT HERE, Y'ALL    ########< xxx >###########
#########\___/############ NOTHING BUT THE CODES  #########\___/############
############################################################################

# (codes)
############################################################################

def setup():
    size(1920, 1080)
    frameRate(1000)

b = Button(10, 10, 200, 50, "Dank Mode", True)
s = Slider(10, 70, 200, 50, "Dankness")
t = Button(10, 130, 200, 50, "Tee F tue",True)

def draw():
    #background(0)   
    textSize(sin(millis()/100)*200+220)
    if b.state:
        colorMode(HSB)
        fill(random(255), 255, 255, random(100, 255))
        colorMode(RGB)
        for x in range(0, 2):
            pushMatrix()
            translate(random(width), random(height))
            rotate(random(200))
            ellipse(random(width), random(height), random(1600), random(1600))
            popMatrix()
        if t.state and False:
            if frameCount%6<3:
                fill(50,205,50)
                background(255,105,180)
            else:
                fill(255,105,180)
                background(50,205,50)
        else:
            if frameCount%6<3:
                colorMode(HSB)
                fill(127+s.state*127, 255, 255, 10)
                rect(0, 0, width, height)
                colorMode(RGB)
                fill(255)
            else:
                colorMode(HSB)
                fill(s.state*random(255), 255, 255, 10)
                rect(0, 0, width, height)
                colorMode(RGB)
                fill(0)
        pushMatrix()
        translate(width/2 + random(-100, 100),height/2)
        rotate(frameCount/60.0 + random(-1, 1))
        translate(sin(frameCount/17.0)*200,cos(frameCount/13.0)*200)
        if random(1) > 0.7:
            scale(-1, 1)
        if(t.state):
            text(".|.,\n..|._",0,0)
        else:
            text("Dank Memes",0,0)
        popMatrix()
        filter(INVERT)
        if random(1) > 0.96:
            filter(THRESHOLD, random(255))
        if random(1)>0.5:
            filter(ERODE)
        else:
            filter(DILATE)
        filter(POSTERIZE, 5)
    
    b.render()
    s.render()
    if s.state is 1:
        t.render()