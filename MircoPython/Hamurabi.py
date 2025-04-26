# hamurabi.py
# Code by Chris Stoddard

import random
import sys

def think_again_grain(grain):
    print(f"HAMURABI: THINK AGAIN. YOU HAVE ONLY {grain} BUSHELS OF GRAIN. NOW THEN,")

def think_again_land(land):
    print(f"HAMURABI: THINK AGAIN. YOU OWN ONLY {land} ACRES. NOW THEN,")

def impossible_request():
    print("\nHAMURABI: I CANNOT DO WHAT YOU WISH.")
    print("GET YOURSELF ANOTHER STEWARD!!!!!")
    sys.exit()

def bell():
    for _ in range(10):
        print("\a", end='')

# Initialize variables
year = 0
people = 95
grain = 2800
harvest = 0
rats = 0
land = 3000
yield_per_acre = 3
land_price = 17
immigrants = 5
starved = 0
total_starved = 0
total_percent_starved = 0
plague_chance = 1  # initialize nonzero to skip plague in year 1

for year in range(1, 11):
    print("\n\nHAMURABI: I BEG TO REPORT TO YOU,")
    if year > 1:
        print(f"IN YEAR {year - 1}, {starved} PEOPLE STARVED, {immigrants} CAME TO THE CITY,")
    people += immigrants

    if plague_chance == 0:
        people = people // 2
        print("A HORRIBLE PLAGUE STRUCK! HALF THE PEOPLE DIED.")

    print(f"POPULATION IS NOW {people}")
    print(f"THE CITY NOW OWNS {land} ACRES.")
    print(f"YOU HARVESTED {yield_per_acre} BUSHELS PER ACRE.")
    print(f"THE RATS ATE {rats} BUSHELS.")
    print(f"YOU NOW HAVE {grain} BUSHELS IN STORE.")

    land_price = random.randint(17, 26)
    print(f"LAND IS TRADING AT {land_price} BUSHELS PER ACRE.")

    # Buying land
    while True:
        try:
            acres_to_buy = int(input("HOW MANY ACRES DO YOU WISH TO BUY? "))
            if acres_to_buy < 0:
                impossible_request()
            if acres_to_buy * land_price > grain:
                think_again_grain(grain)
            else:
                break
        except:
            continue

    if acres_to_buy > 0:
        land += acres_to_buy
        grain -= acres_to_buy * land_price
    else:
        # Selling land
        while True:
            try:
                acres_to_sell = int(input("HOW MANY ACRES DO YOU WISH TO SELL? "))
                if acres_to_sell < 0:
                    impossible_request()
                if acres_to_sell > land:
                    think_again_land(land)
                else:
                    break
            except:
                continue
        land -= acres_to_sell
        grain += acres_to_sell * land_price

    # Feeding people
    while True:
        try:
            grain_to_feed = int(input("HOW MANY BUSHELS DO YOU WISH TO FEED YOUR PEOPLE? "))
            if grain_to_feed < 0:
                impossible_request()
            if grain_to_feed > grain:
                think_again_grain(grain)
            else:
                break
        except:
            continue
    grain -= grain_to_feed

    # Planting crops
    while True:
        try:
            acres_to_plant = int(input("HOW MANY ACRES DO YOU WISH TO PLANT WITH SEED? "))
            if acres_to_plant < 0:
                impossible_request()
            if acres_to_plant > land:
                think_again_land(land)
            elif acres_to_plant // 2 > grain:
                think_again_grain(grain)
            elif acres_to_plant > people * 10:
                print(f"BUT YOU HAVE ONLY {people} PEOPLE TO TEND THE FIELDS! NOW THEN,")
            else:
                break
        except:
            continue
    grain -= acres_to_plant // 2

    # Harvest
    yield_per_acre = random.randint(1, 5)
    harvest = acres_to_plant * yield_per_acre

    # Rats
    rats = 0
    if random.randint(0, 1) == 0:
        rats = grain // yield_per_acre
    grain += harvest - rats

    # Population changes
    babies = int(yield_per_acre * (20 * land + grain) / people / 100 + 1)
    immigrants = babies
    people_fed = grain_to_feed // 20

    # Plague chance
    plague_chance = int(10 * (2 * random.random() - 0.3))

    # Starvation
    if people_fed < people:
        starved = people - people_fed
        percent_starved = (100.0 * starved) / people
        if percent_starved > 45:
            print("\nYOU STARVED", starved, "PEOPLE IN ONE YEAR!!!")
            print("DUE TO THIS EXTREME MISMANAGEMENT YOU HAVE NOT ONLY")
            print("BEEN IMPEACHED AND THROWN OUT OF OFFICE BUT YOU HAVE")
            print("ALSO BEEN DECLARED NATIONAL FINK!!!!")
            sys.exit()
    else:
        starved = 0
        percent_starved = 0

    total_starved += starved
    total_percent_starved += percent_starved
    people -= starved

# End of 10 years
acres_per_person = land // people
avg_starved = total_percent_starved // 10

print("\nIN YOUR 10-YEAR TERM OF OFFICE,", avg_starved, "% OF THE")
print("POPULATION STARVED PER YEAR ON THE AVERAGE.")
print(f"A TOTAL OF {total_starved} PEOPLE DIED!!")
print("YOU STARTED WITH 10 ACRES PER PERSON AND ENDED WITH")
print(f"{acres_per_person} ACRES PER PERSON.")

if avg_starved > 33 or acres_per_person < 7:
    print("YOU STARVED TOO MANY AND LOST TOO MUCH LAND!")
    print("YOU HAVE BEEN DECLARED A DISASTER!")
elif avg_starved <= 10 and acres_per_person >= 9:
    print("A FANTASTIC PERFORMANCE!!! CHARLEMAGNE, DISRAELI, AND")
    print("JEFFERSON COMBINED COULD NOT HAVE DONE BETTER!")
elif avg_starved > 3 or acres_per_person < 10:
    print("YOUR PERFORMANCE COULD HAVE BEEN SOMEWHAT BETTER.")
    print(f"{int(people * 0.8 * random.random())} PEOPLE WOULD DEARLY LIKE TO SEE YOU ASSASSINATED.")
else:
    print("YOUR HEAVY-HANDED PERFORMANCE SMACKS OF NERO AND IVAN IV.")
    print("THE PEOPLE (REMAINING) FIND YOU AN UNPLEASANT RULER AND,")
    print("FRANKLY, HATE YOUR GUTS!!")

bell()
print("\n\nSO LONG FOR NOW.")
sys.exit()
