///plant feature catagories
#define PLANT_FEATURE_FRUIT (1<<0)
#define PLANT_FEATURE_BODY (1<<1)
#define PLANT_FEATURE_ROOTS (1<<2)

/*
	Plant stat values
*/
//Body stat values
	//How many fruits this plant produces per yield
#define PLANT_BODY_HARVEST_MICRO 1
#define PLANT_BODY_HARVEST_SMALL 3
#define PLANT_BODY_HARVEST_MEDIUM 6
#define PLANT_BODY_HARVEST_LARGE 10
	//How many times can this plant be harvested
#define PLANT_BODY_YIELD_MICRO 1
#define PLANT_BODY_YIELD_SMALL 3
#define PLANT_BODY_YIELD_MEDIUM 5
#define PLANT_BODY_YIELD_LARGE 10
#define PLANT_BODY_YIELD_FOREVER INFINITY
	//How long between yields
#define PLANT_BODY_YIELD_TIME_SLOW 30 SECONDS
#define PLANT_BODY_YIELD_TIME_MEDIUM 15 SECONDS
#define PLANT_BODY_YIELD_TIME_FAST 5 SECONDS
	//How many planter slots does this body take up
#define PLANT_BODY_SLOT_SIZE_SMALL 1
#define PLANT_BODY_SLOT_SIZE_MEDIUM 3
#define PLANT_BODY_SLOT_SIZE_LARGE 5

//Fruit stat values
	//How many reagents can the fruit hold
#define PLANT_FRUIT_VOLUME_MICRO 5
#define PLANT_FRUIT_VOLUME_SMALL 10
#define PLANT_FRUIT_VOLUME_MEDIUM 25
#define PLANT_FRUIT_VOLUME_LARGE 50
#define PLANT_FRUIT_VOLUME_VERY_LARGE 80
	//How long it takes the fruit to grow to maturity
#define PLANT_FRUIT_GROWTH_SLOW 60 SECONDS
#define PLANT_FRUIT_GROWTH_MEDIUM 30 SECONDS
#define PLANT_FRUIT_GROWTH_FAST 20 SECONDS
#define PLANT_FRUIT_GROWTH_VERY_FAST 5 SECONDS

//Reagent values as a %
#define PLANT_REAGENT_MICRO 5
#define PLANT_REAGENT_SMALL 15
#define PLANT_REAGENT_MEDIUM 25
#define PLANT_REAGENT_LARGE 45
#define PLANT_REAGENT_VERY_LARGE 75

///Substrate flags
#define PLANT_SUBSTRATE_DIRT (1<<0)
#define PLANT_SUBSTRATE_SAND (1<<1)
#define PLANT_SUBSTRATE_CLAY (1<<2)
#define PLANT_SUBSTRATE_DEBRIS (1<<3)
