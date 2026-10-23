## Example 1

# class Car :

#     def __init__(self, make, model, year, color):
#         self.make = make
#         self.model = model
#         self.year = year
#         self.color = color

#     def drive(self) :
#         print(f"This {self.model} is driving")
    
#     def stop(self) :
#         print(f"This {self.model} is stopped")

# car_1 = Car("Chevy", "Corvette", 2021, "Blue")
# car_2 = Car("Ford", "Mustang", 2022, "Red")

# print(car_1.make)
# print(car_1.model)
# print(car_1.year)
# print(car_1.color)

# car_1.drive()
# car_1.stop()

# car_2.drive()
# car_2.stop()

## Example 2

class Microwave :
    def __init__(self, brand : str, power_rating : str) -> None:
        self.brand = brand
        self.power_rating = power_rating
        self.turned_on : bool = False

    def turn_on(self) -> None :
        if self.turned_on :
            print(f"Microwave ({self.brand}) is already turned on")
        else :
            self.turned_on = True
            print(f"Microwave ({self.brand}) is now turned on")

    def turn_off(self) -> None :
        if self.turned_on :
            self.turned_on = False
            print(f"Microwave ({self.brand}) is now turned off")
        else :
            print(f"Microwave ({self.brand}) is already turned on") 
    
    def run(self, seconds : int) -> None :
        if self.turned_on :
            print(f"Running ({self.brand}) for {seconds} seconds")
        else :
            print(f"A mystical force whispers : 'Turn on your microwave first...'")



smeg : Microwave = Microwave(brand = "Smeg", power_rating ="B")
print(smeg)
print(smeg.brand)
print(smeg.power_rating)

smeg.turn_on()
smeg.turn_on()
smeg.run(5)
smeg.turn_off()


