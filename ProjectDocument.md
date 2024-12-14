# Resident Medieval #

IMPORTANT: Converting our Godot project to HTML caused the web version of the game to break. Please play the game by downloading the zip file called ResidentMedieval.zip and launching Godot using this link: https://drive.google.com/file/d/1tfXmzc50zvNG8Jq4TXfSyPP31eo42mPe/view?usp=sharing. The game works with no issues this way.

## Summary ##

An action horror game set in a dark and eerie Victorian-era Gothic mansion, where your primary goal is to escape the nightmarish environment. As the game begins, you wake up alone in a dimly lit room, disoriented and with no recollection of how you arrived. The unsettling silence is broken only by distant, chilling noises, setting the tone for the terrifying journey ahead. Driven by a mix of fear and curiosity, you start to explore the shadowy corridors and decrepit streets, only to discover that the place is teeming with hostile, "infected" individuals who are out for blood. To survive, you must navigate a labyrinth of interconnected rooms, passageways, and outdoor areas, all while solving puzzles, using weapons, and piecing together the mansion’s dark secrets. The infected are relentless, and your limited supply of resources forces you to make tough decisions: do you risk engaging them head-on, or attempt to sneak past unnoticed?

**A paragraph-length pitch for your game.**

Resident Medieval is a pulse-pounding action-horror game where you must navigate a sinister mansion teeming with infected enemies, solve cryptic puzzles, and make life-or-death decisions to survive the night. Fight or flee as you uncover the mansion’s dark secrets, all while conserving your limited resources to make it out alive. Action-horror games often focus on combat or stealth, but Resident Medieval blends both with a resource-constrained survival element and intricate environmental puzzles. There is always constant tension between engaging enemies and sneaking past them adds a unique, strategic layer to the gameplay. Jump into the action and give it a try!

## Project Resources
IMPORTANT: Converting our Godot project to HTML caused the web version of the game to break. Please play the game by downloading the zip file called ResidentMedieval.zip and launching Godot using this link: https://drive.google.com/file/d/1tfXmzc50zvNG8Jq4TXfSyPP31eo42mPe/view?usp=sharing. The game works with no issues this way.

[Web-playable version of your game.](https://noahmchang.itch.io/resident-medieval) Password: 11037 (SEE NOTE ABOVE)

[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal](https://docs.google.com/document/d/1M7M3UT2rDdXSgoVlukvLziJDm2PqogjL-ExfxdbDmNA/edit?usp=sharing)  

## Gameplay Explanation ##

Controls are WASD to move, shift to run, E to interact, left click to use weapon, I for inventory, #1-9 to select inventory slot. Interact with cabinets to obtain items. In some rooms, enemies will be constantly spawned from spawners, so running from them is a valid way to play the game. In terms of weaponry, there is a knife which is unlimited and a pistol which takes ammo. There are three times of enemies, normal melee zombies, ranged zombies, and slasher zombies which are slightly stronger. Enemy AI gets alerted by player and follows player through ray casting. The first puzzle is a room where you have to interact with the cabinets in a certain order to unlock the door. There will be a hint based on the text (2:00 then 5:00) and the clock pattern on the carpet. When at the second puzzle, the player notices that there is no door for the next room. The player must interact with the matches on a cabinet to burn away the firewood in the fireplace to unlock a passage.

NOTE: You aim by your mouse position (even your knife).

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**

Optimal strategy would be a mix of fighting and running when you get overwhelmed by enemies. As mentioned, the you can select items in your inventory by using the the 1-9 keys. Save your pistol for tough enemies since you will only receive a small amount of ammo. Switch to your knife on weaker enemies since the knife can be used without any cost. Finally, run by holding the shift key in short bursts to make sure you do not get fatigued. The health and fatigue bar can be viewed at the top-left of the screen.

**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

Our group did not use code from any external source. However, we referenced the Godot Docs to understand how to implement certain features: https://docs.godotengine.org/en/stable/index.html

# Main Roles #

Your goal is to relate the work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

## Producer - Andrew Lov

**Describe the steps you took in your role as producer. Typical items include group scheduling mechanisms, links to meeting notes, descriptions of team logistics problems with their resolution, project organization tools (e.g., timelines, dependency/task tracking, Gantt charts, etc.), and repository management methodology.**

My role as the producer of our game was acting as an organizer/overseer of the development, and also helping out to do tasks that didn't have anyone explicitly assigned to it. There were a lot of tasks that I did contribute to, including level desgin, puzzle implementation.

Part of my job as producer had been alleviated by the format of how our group functioned, as Sween had handled the base creation of the shared Github repository that we all worked on. From the way that our architect wanted to lay the foundation of our code, Sween created a playable version of our game that had all necessary mechanics and scripts to create the rest of the game ourselves, where we could work independently of one another. This was really helpful, and Sween did this on his own accord.

There were other things that I laid out that would help in the course of development of our game, including a Gantt Chart that would show the order in which our group should proceed in for development ![Gantt Chart](https://cdn.discordapp.com/attachments/1111584119541993472/1317261406579720243/Core_Gameplay_Mechanics_1.png?ex=675e0ac8&is=675cb948&hm=7503a53a80d7a6769f950895f451840d01a9b9a0ec9eebf2a1632622c3333aec&)

I did schedule meetings together for our group, and provided resources that could be referenced by the other group members. It was definitely a group effort though, where everyone did their part with communciation, making organization pretty straightforward. We were able to communicate via our group chat in Discord, where everyone could state their availability and when they could meet. We met before our Initial Plan, about a week into development during Discussion Time for our class, and whenever possible when it was close to the festival time. Everyone was on top of their communication, where they let each other know about their progress and expected time frames for when something would be implemented or pushed.

We did encounter errors that would occur, such as collisions when trying to merge our work all into one project. The testing and compilation usually happened on my end or with the Architect, who was also involved with version control and wanting to make sure each version functioned corerctly. This would include trying to make sure no one would push any changes to the repository, or only taking files that were added or heavily updated from each category. There would be issues with UI, for example, that would cause problems with the functionality with our game. After reverting to previous commits that we had that were working, it was easier to debug the issues that were causing problems that would crash the game, where we had each member add their changes in a sequential order to make sure that things did not break.

# Level Design 
I worked hand in hand with our head of Game Logic Noah, where together we were able to draft together the base layout of our game after taking into consideration the narrative elements that we wanted to convey in the gameplay. Together we came up with a design that would feature 10 levels, where this would have a compilation of puzzle rooms and combat to ensure a unique experience for each level.

I personally worked on levels 6-10 of our game, where this would be the latter half of levels that the player would make their way through. Using the images and sprites from our art designer Jose, I tilemapped each level after creating a base layout, painted collisions so that the player was confined to the dimensions of the room for the level, and designed each room by picking which of the sprites for each tile to use for each room to fit the story and build suspense. Additionally, using the sprites that Jose had provided, I made furniture and such so that the levels wouldn't feel so bare.

One of the key parts of our game are the puzzles that were implemented, and I had worked on one of the two puzzles after coming up with the idea for a creative puzzle that fit the narrative of our story. This was found in level 7, where this would include a fireplace that initially only had firewood in it. The theory was to have the player pick up a set of matches as an interactable item from a previous level, where they would use these matches in the fireplace. This would play an animation that showed the firewood burning, followed by a new sprite showing that the fireplace now had a hole in it that was before blocked by the firewood. This would allow the entry into the next room, which would be an ominous hallway leading to the boss room. Initially, I wanted to have it so you needed the item and interacted with the fireplace, where you could have a choice to light it or not once in possession of the matches. However, it was implemented as a switch, and in the same room such that you could see the fire and the animation occur. There wasn't a sprite for the fireplace , but I found and [replicated](https://www.megavoxels.com/learn/how-to-make-a-pixel-art-fireplace/) a pixel art of the fireplace that Jose would later animate and alter to create a firewood sprite as well. I implemented the animation for the fireplace, and sprite transition to make the burning wood look sequentially sound. 

## User Interface and Input

**Describe your user interface and how it relates to gameplay. This can be done via the template.**
**Describe the default input configuration.**

**Add an entry for each platform or input style your project supports.**

## Movement/Physics

**Describe the basics of movement and physics in your game. Is it the standard physics model? What did you change or modify? Did you make your movement scripts that do not use the physics system?**

## Animation and Visuals

**List your assets, including their sources and licenses.**

**Describe how your work intersects with game feel, graphic design, and world-building. Include your visual style guide if one exists.**

## Game Logic - Noah Chang

**Document the game states and game data you managed and the design patterns you used to complete your task.**

# Sub-Roles

## Audio

**List your assets, including their sources and licenses.**

**Describe the implementation of your audio system.**

**Document the sound style.** 

## Gameplay Testing - Andrew Lov

**Add a link to the full results of your gameplay tests.**

**Summarize the key findings from your gameplay tests.**

## Narrative Design - Andrew Lov

**Document how the narrative is present in the game via assets, gameplay systems, and gameplay.** 

## Press Kit and Trailer

**Include links to your presskit materials and trailer.**

**Describe how you showcased your work. How did you choose what to show in the trailer? Why did you choose your screenshots?**

## Game Feel and Polish - Noah Chang

**Document what you added to and how you tweaked your game to improve its game feel.**
