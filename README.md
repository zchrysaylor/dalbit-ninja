# lua-boy-advance

A well-structured, thoroughly documented LÖVE (Love2d) project. This project contains many of the primitives needed to build up a GBA-style 2D game (Pokémon, Zelda, Mario & Luigi: Superstar Saga, etc).

## Project Structure

The project uses two main important concepts: Vessels and StateMachines.

### Vessels

Heavily inspired by the great Challacade (see References), all things that exist in the world (i.e. love.physics bodies) are considered "Vessels". A Vessel can be one of two types: "Soul", an entity which moves dynamically (i.e. the player or npcs), and "Husk", an object with physics properties that does not move dynamically (i.e. breakable boxes, trees, etc).

### State Machine

Heavily inspired by GD50 (see References), most of the game logic is controlled via a state machine.

## Resources

- [Challacade](https://www.youtube.com/@Challacade)
- [GD50](https://youtube.com/playlist?list=PLhQjrBD2T383Vx9-4vJYFsJbvZ_D17Qzh&si=jj8o_NLrpyr_ezwn)
