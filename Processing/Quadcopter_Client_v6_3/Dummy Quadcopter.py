
# Prismafire, the new QuagMire
# Quadcopter flight software
# @authors Adam Lastowka, Benjamin Welsh, Anthony Catalano-Johnson

# Update the 4th number for any changes at all, except for medium changes, update 3rd, major changes update 2nd.
#           Rev: 0.0.0.2
#   |____   \ /  \ /  \ /   ____|
#        \   V    V    V   /
#         \_______________/

print("________       _____                         ____________")
print("___  __ \_________(_)_____________ _________ ___  __/__(_)___________ ")
print("__  /_/ /_  ___/_  /__  ___/_  __ `__ \  __ `/_  /_ __  /__  ___/  _ \ ")
print("_  ____/_  /   _  / _(__  )_  / / / / / /_/ /_  __/ _  / _  /   /  __/")
print("/_/     /_/    /_/  /____/ /_/ /_/ /_/\__,_/ /_/    /_/  /_/    \___/")

print('Importing libraries...')
import time
import math
import socket
import os
print('Libraries imported. Prismafire online.\a')

#----------------------------------------------------------------------#

# The cap on the value that can be stored in the "integral" variable.

#----------------------------------------------------------------------#

# "Kick" the motors to get them to start up.
print('Motor initialization commencing...')
print('Motors online.')

def run():
        #----------------------------------------------------------------------#

        print('Network architecture initializing...')

        # Create a new socket called "sock", and set it up.
        sock = socket.socket()
        port = 42042
        sock.bind(('',port)) #leaving the ip blank stands for all ports
        sock.listen(1)
        print('Architecture online, waiting for connections...')
        # This will loop until a connection passing sufficient data
        # to the quadcopter
        # 'link' is now the connection
        while True:
                link, addr = sock.accept()
                time.sleep(1)
                if(len(link.recv(64))>4):
                        break
        print('connection created with: '+addr[0])
        link.settimeout(.1)
        #----------------------------------------------------------------------#

        print("""\aFlight systems online, stabilization systems active,
               ready to fly.""")
        isConnected = 10
        ticksPassed = 0
        Kp = 0.0
        Ki = 0.0
        Kd = 0.0
        throttle = 0.0
        X = 0.0
        Y = 0.0
        Z = 0.0
        # Set this to the starting time value so that the deltaT in
        # our first iteration is not completely crazy.
        previous_time = time.time()
        while isConnected:
                if ticksPassed % 2 == 0:
                        # Send the motor speeds from the previous tick back
                        # to the controlling computer every once in a while.

                        # <ticks/ax/ay/az>
                        tx_packet="<%i/%.3f/%.3f/%.3f/>"%(ticksPassed,
                                  math.cos(float(ticksPassed)/91.0)*0.2, math.sin(float(ticksPassed)/173.0)*0.2, math.sin(ticksPassed/50))
                        #If the client isn't there, break out of the loop.
                        try:
                                link.sendall(tx_packet.encode())
                        except socket.error:
                                isConnected = 0
                                break

                        # RX  RX  RX  RX
                        # <P|I|D|throt|X|Y|Z>
                        try:
                            packet=link.recv(9092)
                        except socket.error:
                                isConnected = 0
                                break
                        except socket.timeout:
                            isConnected-=1
                        else:
                            isConnected=10
                            try:
                                #print(packet)
                                cmdSet=packet.decode('utf-8').split('$')[-1].split("%")[0].split('~')
                                #print(cmdSet)
                            except IndexError:
                                print('IndexERR')
                                pass
                            else:
                                try:
                #                    print packet, cmdSet
                                   if len(cmdSet)==7:
                                         Kp, Ki, Kd, throttle, X, Y, Z = [float(x) for x in cmdSet]
                                except ValueError:
                                        pass

                print('recvd', Kp, Ki, Kd, throttle, X, Y, Z)
                #----------------------------------------------------------------------#
                ticksPassed += 1
                time.sleep(1/50.0)

        #----------------------------------------------------------------------#

        # If the client disconnects, we are either already on the ground,
        # or something is about to go terribly wrong.
        # In either case, we will not be going up.
        print('\nConnection lost. Descending.')
        time.sleep(1)

        # Close sockets so ports are freed up as the next program runs.
        link.close()
        sock.close()
        del link, sock

        print('Restarting QuagMire.run()')

        #----------------------------------------------------------------------#

if __name__=="__main__":
    while True:
        run()



