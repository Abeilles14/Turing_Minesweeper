% Isabelle Andre
% 25 january 2015
% ICS3UI-01
% Mr. J-D
% MINESWEEPER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%% GLOBAL VARIABLES %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

import GUI

%%%%% Window IDs
var win_INTRO : int                             %intro
var win_LEVEL : int                             %level settings
var win_HELP : int                              %instructions
var win_MINESWEEPER : int                       %main game window
var win_WIN : int                               %win alert
var win_LOSE : int                              %lose alert

%%%%% Game Conditions
var gameover : boolean                          %deathflag
var newgame : boolean
var leave : boolean                             %exit whole program sentinel
var level1 : boolean := false                   %level selection
var level2 : boolean := false
var level3 : boolean := false

%%%%% Sizing
const border_x : int := 15                      %map borders around gameboard (15 pixels all around)
const border_y : int := 15
var boardsize_x, boardsize_y : int              %board either 8x8, 16x16 or 32x16 tiles.
var cellsize_x, cellsize_y : int                %cells are 16x16 pixels
var size_x, size_y : int                        %preset bordsize
var x_squares, y_squares : int                  %preset total number of squares on board

%%%%% Map
var minecell : int                              %number of hidden mines
var mapempty : int := 0                         %mines are all discovered
var minecount : int                             %minetiles found countdown
var finaltime : int                             %player win time

%%%%% Images
var pic_GAMEHELP : int := Pic.FileNew ("help_gamepic.bmp")
var pic_TILESHELP : int := Pic.FileNew ("help_tilespic.bmp")
var pic_BOMBHELP : int := Pic.FileNew ("help_bombpic.bmp")
var pic_MINESWEEPER : int := Pic.FileNew ("Minesweeper_Icon.bmp")
var pic_UNOPENED : int := Pic.FileNew ("unopened.bmp")
var pic_FLAG : int := Pic.FileNew ("bombflagged.bmp")
var pic_QUESTION : int := Pic.FileNew ("bombquestion.bmp")
var pic_MISFLAG : int := Pic.FileNew ("misflag.bmp")
var pic_BOMBREVEALED : int := Pic.FileNew ("bombrevealed.bmp")
var pic_BOMBDEATH : int := Pic.FileNew ("bombdeath.bmp")
var pic_TIMENEG := Pic.FileNew ("time-.bmp")

var pic_TIME : array 0 .. 9 of int
for number : 0 .. 9
    pic_TIME (number) := Pic.FileNew ("time" + intstr (number) + ".bmp")
end for

var pic_NUMBER : array 0 .. 8 of int
for number : 0 .. 8
    pic_NUMBER (number) := Pic.FileNew ("open" + intstr (number) + ".bmp")
end for

%%%%% Fonts
var font_INTRO : int := Font.New ("Castellar:50:bold")
var font_HELP : int := Font.New ("Constantia:11")
var font_LEVEL : int := Font.New ("Castellar:30:bold")
var font_ALERT : int := Font.New ("Castellar:50:bold")
var font_TIME : int := Font.New ("Castellar:15")

%%%%% Music Sounds & Audio
process aud_THEME
    Music.PlayFileLoop ("tetris_remix.wav")
end aud_THEME

process aud_WINNER
    Music.PlayFile ("winner.wav")
end aud_WINNER

process aud_LOSER
    Music.PlayFile ("loser.wav")
end aud_LOSER

process aud_BOOM
    Music.PlayFile ("bomb.wav")
end aud_BOOM

%%%%% Mouse
buttonchoose ("multibutton")
const MOUSE_nothing := 0                                %player hasnt clicked yet
const MOUSE_opened := 1                                 %player has opened a cell (1L)
const MOUSE_flagged := 2                                %player has flagged a cell (1R)
const MOUSE_questionmark := 3                           %player has question marked a cell (2R)

var mouse_x, mouse_y, mouse_button, mouse_button_pressed : int := 0  %mouse location and buttons
var mouse_area_x, mouse_area_y : int                                 %mouse grid



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% GAME INTRO %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% INTRO %%%%%%%%%%

procedure intro
    win_INTRO := Window.Open ("graphics:800;250, position:center,400, nooffscreenonly, nobuttonbar, title:Welcome")

    colourback (79)
    for backgroundB : 0 .. 40
	put repeat (" ", 20)
    end for

    Pic.Draw (pic_MINESWEEPER, 10, 10, picMerge)

    Font.Draw ("MINESWEEPER", 250, 150, font_INTRO, 30)

    drawline (250, 140, 770, 140, 30)
    drawline (250, 130, 770, 130, 30)

    Font.Draw ("Created by Isabelle Andre", 260, 100, defFontID, 30)
end intro

%%%%%%%%%% INSTRUCTIONS %%%%%%%%%%

procedure ok                                                          %exit button for help window
    Window.Close (win_HELP)
    GUI.Quit
end ok

procedure help
    var instructions : string
    var help_file : int

    win_HELP := Window.Open ("graphics:800;600, position:center,400, title:How To Play")

    colourback (79)
    for background : 0 .. 40                                             %background
	put repeat (" ", 20)
    end for

    Pic.Draw (pic_GAMEHELP, 580, 350, picCopy)
    Pic.Draw (pic_TILESHELP, 600, 200, picCopy)
    Pic.Draw (pic_BOMBHELP, 600, 70, picCopy)

    Font.Draw ("HOW TO PLAY", 1, 550, font_LEVEL, 30)

    open : help_file, "Minesweeper_help.txt", get                           %opens instructions file
    assert help_file > 0
    for counter : 1 .. 22
	get : help_file, instructions : *
	Font.Draw (instructions, 5, 530 - (counter * 23), font_HELP, 16)     %writes text in font
    end for

    var button0 := GUI.CreateButton (730, 15, 20, "OK", ok)                 %exits help window to start level selection

    loop
	exit when GUI.ProcessEvent
    end loop
    GUI.ResetQuit
end help

%%%%%%%%%% LEVEL %%%%%%%%%%

procedure beg                                    %beginner - 8x8 tiles, 10 mines
    size_x := 8
    size_y := 8
    minecell := 10
    x_squares := size_x * size_y
    y_squares := size_x * size_y
    level1 := true
    GUI.Quit
end beg

procedure inter                             %intermediate - 16x16 tiles, 40 mines
    size_x := 16
    size_y := 16
    minecell := 40
    x_squares := size_x * size_y
    y_squares := size_x * size_y
    level2 := true
    GUI.Quit
end inter

procedure adv                                  %intermediate - 32x16 tiles, 99 mines
    size_x := 32
    size_y := 16
    minecell := 99
    x_squares := size_x * size_y
    y_squares := size_x * size_y
    level3 := true
    GUI.Quit
end adv

procedure level                                %level selection (beginner, intermediate, advanced)
    win_LEVEL := Window.Open ("graphics:500;250, position:center,400, title:Level Select")

    colourback (79)
    for background : 0 .. 40
	put repeat (" ", 20)
    end for

    Font.Draw ("SELECT LEVEL", 100, 150, font_LEVEL, 30)
    drawline (100, 140, 400, 140, 30)
    drawline (100, 130, 400, 130, 30)

    var button1 := GUI.CreateButton (70, 50, 20, "Beginner", beg)
    var button2 := GUI.CreateButton (200, 50, 20, "Intermediate", inter)
    var button3 := GUI.CreateButton (350, 50, 20, "Advanced", adv)

    loop
	exit when GUI.ProcessEvent
    end loop
    GUI.Disable (button1)                                    %buttons can no longer be used or show up (glitch fix)
    GUI.Disable (button2)
    GUI.Disable (button3)
    GUI.ResetQuit
    Window.Close (win_LEVEL)
end level



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%% MAIN CODE (INTRO) %%%%%%%%%%%                   %USER SELECTS GAME SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

intro                                                           %intro page
delay (5000)
Window.Close (win_INTRO)

help                                                           %help window pop up
level                                                           %player chooses game settings

var cell : array 1 .. x_squares, 1 .. y_squares of int         %tiles location
var player : array 1 .. x_squares, 1 .. y_squares of int       %what is the player doing




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% GAME PREP %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% PREP MAP %%%%%%%%%%%                           %map settings

procedure mapprep (size_x, size_y : int)                   %map size (8x8/16x16/32x16)

    gameover := false
    newgame := false
    leave := false

    boardsize_x := size_x
    boardsize_y := size_y

    cellsize_x := (maxx - (border_x * 2)) div boardsize_x           %finding cell size (16x16 pixels)
    cellsize_y := (maxy - (border_y * 2 + 49)) div boardsize_y

    minecount := minecell                                           %minecount

    for x : 1 .. x_squares                                          %initializing gameboard
	for y : 1 .. y_squares
	    cell (x, y) := mapempty
	    player (x, y) := MOUSE_nothing
	end for
    end for

end mapprep

%%%%%%%%%%%% PREP MINES %%%%%%%%%%%

%%%%% Hides ONE mine
procedure hide_one_mine (x, y : int)                             %(rand, rand) - see procedure hide_mines below
    cell (x, y) := minecell

    var corner_x, corner_y : int

    for x_around : -1 .. 1
	for y_around : -1 .. 1

	    corner_x := x + x_around                             %finds all 4 corners of the mine
	    corner_y := y + y_around

	    if corner_x > 0 and corner_x <= boardsize_x and corner_y > 0 and corner_y <= boardsize_y
		    and cell (corner_x, corner_y) not= minecell then
		cell (corner_x, corner_y) := cell (corner_x, corner_y) + 1      %Add one (numbers) to surrounding squares
	    end if

	end for
    end for
end hide_one_mine


%%%%% Hides ALL mines
procedure hide_mines                                     %Places mines at random, no overlapping.

    var num_mines : int := minecell
    var cell_x, cell_y : int

    for i : 1 .. num_mines

	loop                                             %searches random cells until finding one without a mine
	    randint (cell_x, 1, size_x)
	    randint (cell_y, 1, size_y)

	    if cell (cell_x, cell_y) not= minecell then     %makes sure there is no overlapping of mines
		hide_one_mine (cell_x, cell_y)              %calls the hide_one_mine procedure to place mine
		exit
	    end if

	end loop
    end for
end hide_mines



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% GAME MAP %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% DRAWS MAP %%%%%%%%%%

procedure mapdraw
    var draw_x, draw_y : int

    %%%%% Map borders
    drawfillbox (1, 1, maxx, maxy, 29)                              %map colors
    drawfillbox (16, maxy - 49, maxx - 16, maxy - 16, 27)

    drawfillbox (1, 1, maxx, 2, 25)                                   %outside lines
    drawfillbox (maxx - 2, 1, maxx, maxy, darkgray)

    drawfillbox (13, 15, 16, maxy - 64, darkgray)                    %inside lines
    drawfillbox (15, maxy - 65, maxx - 15, maxy - 63, darkgray)

    drawfillbox (15, 16, maxx - 15, 12, white)
    drawfillbox (maxx - 17, 14, maxx - 14, maxy - 64, white)

    Pic.Draw (pic_BOMBREVEALED, maxx div 2 - 7, maxy - 39, picCopy)        %just a pic for decoration :)

    %%%%% Draws pictures
    for x : 1 .. size_x
	for y : 1 .. size_y
	    draw_x := floor (((x - 1) * 16) + border_x)                       %places cells, not overlapping borders
	    draw_y := floor ((y - 1) * 16 + border_y)

	    case player (x, y) of

		label MOUSE_nothing :
		    if gameover = true and cell (x, y) = minecell then        %Reveals all bombs if gameover
			Pic.Draw (pic_BOMBREVEALED, draw_x, draw_y, picCopy)
		    else
			Pic.Draw (pic_UNOPENED, draw_x, draw_y, picCopy)       %Cells are unopened if player does not click
		    end if

		label MOUSE_opened :
		    if cell (x, y) = minecell then
			Pic.Draw (pic_BOMBDEATH, draw_x, draw_y, picCopy)       %If bomb clicked, bomb cell 'explodes'
		    else
			Pic.Draw (pic_NUMBER (cell (x, y)), draw_x, draw_y, picCopy) %If bomb not clicked, show number/blank
		    end if

		label MOUSE_flagged :
		    if gameover and cell (x, y) not= minecell then
			Pic.Draw (pic_MISFLAG, draw_x, draw_y, picCopy)         %If gameover and player flagged a number/blank, show misflag
		    else
			Pic.Draw (pic_FLAG, draw_x, draw_y, picCopy)            %If player right clicks, show flag
		    end if

		label MOUSE_questionmark :
		    if gameover = true and cell (x, y) = minecell then
			Pic.Draw (pic_BOMBREVEALED, draw_x, draw_y, picCopy)
		    else
			Pic.Draw (pic_QUESTION, draw_x, draw_y, picCopy)        %If player right clicks twice, show questionmark
		    end if
	    end case

	end for
    end for

    %%%%%%%%%%% Minecount %%%%%%%%%

    if length (intstr (minecount)) = 1 then                              %1 digit
	Pic.Draw (pic_TIME (0), 21, maxy - 44, picCopy)
	Pic.Draw (pic_TIME (0), 34, maxy - 44, picCopy)
	Pic.Draw (pic_TIME (minecount), 47, maxy - 44, picCopy)

    elsif length (intstr (minecount)) = 2 then
	if minecount < 0 then                                             %If number is negative
	    Pic.Draw (pic_TIME (0), 21, maxy - 44, picCopy)
	    Pic.Draw (pic_TIMENEG, 34, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (strint ((intstr (minecount) (2)))), 47, maxy - 44, picCopy)
	else
	    Pic.Draw (pic_TIME (0), 21, maxy - 44, picCopy)              %2 digits
	    Pic.Draw (pic_TIME (strint (intstr (minecount) (1))), 34, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (strint ((intstr (minecount) (2)))), 47, maxy - 44, picCopy)
	end if

    elsif length (intstr (minecount)) = 3 then
	if minecount < 0 then                                              %If number is negative
	    Pic.Draw (pic_TIMENEG, 21, maxy - 38, picCopy)
	    Pic.Draw (pic_TIME (strint (intstr (minecount) (2))), 34, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (strint ((intstr (minecount) (3)))), 47, maxy - 44, picCopy)
	else                                                               %3 digits
	    Pic.Draw (pic_TIME (strint ((intstr (minecount) (1)))), 21, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (strint ((intstr (minecount) (2)))), 34, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (strint ((intstr (minecount) (3)))), 47, maxy - 44, picCopy)
	end if
    end if

    View.Update
end mapdraw

%%%%%%%%%% REVEAL MAP %%%%%%%%%%

procedure death_reveal                           %Player lost, reveals game mapmines
    for x : 1 .. boardsize_x
	for y : 1 .. boardsize_y
	    if player (x, y) = MOUSE_nothing and cell (x, y) = minecell then
		mapdraw
	    end if
	end for
    end for
end death_reveal

%%%%%%%%%% REVEAL EMPTY CELLS %%%%%%%%%

procedure empty_cells (x, y : int)               %Player clicks on an empty cell.
    player (x, y) := MOUSE_opened                %Left click on empty space

    for x_side : -1 .. 1                        %Opens corners
	for y_side : -1 .. 1

	    if (x_side not= 0 or y_side not= 0) and x + x_side > 0 and x + x_side <= boardsize_x and y + y_side > 0 and y + y_side <= boardsize_y then
		if cell (x + x_side, y + y_side) = mapempty and player (x + x_side, y + y_side) not= MOUSE_opened then
		    empty_cells (x + x_side, y + y_side)
		else
		    player (x + x_side, y + y_side) := MOUSE_opened
		end if
	    end if

	end for
    end for
end empty_cells

%%%%%%%%%% CHECK FOR WIN %%%%%%%%%%

function player_win : boolean                        %Checks if player has opened whole gameboard correctly

    for x : 1 .. boardsize_x
	for y : 1 .. boardsize_y

	    if cell (x, y) = minecell then           %Checks if all minecells were flagged
		if player (x, y) not= MOUSE_flagged then
		    result false
		end if

	    else

		if player (x, y) not= MOUSE_opened then %Checks if whole gameboard was opened
		    result false
		end if

	    end if
	end for
    end for

    result true
end player_win

%%%%%%%%%% TIMER %%%%%%%%%%
var endtime : int
process timer                                              %Game timer
    var seconds : int
    var millisecs : int := 0

    loop
	millisecs := millisecs + 1
	seconds := millisecs div 10000                  %converts time into seconds

	if length (intstr (seconds)) = 1 then           %1 digit
	    Pic.Draw (pic_TIME (0), maxx - 60, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (0), maxx - 47, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (round (seconds)), maxx - 34, maxy - 44, picCopy)

	elsif length (intstr (seconds)) = 2 then       %2 digits
	    Pic.Draw (pic_TIME (0), maxx - 60, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (round (seconds div 10)), maxx - 47, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (round (strint ((intstr (seconds) (2))))), maxx - 34, maxy - 44, picCopy)

	elsif length (intstr (seconds)) = 3 then        %3 digits
	    Pic.Draw (pic_TIME (round (seconds div 100)), maxx - 60, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (round (strint ((intstr (seconds) (2))))), maxx - 47, maxy - 44, picCopy)
	    Pic.Draw (pic_TIME (round (strint ((intstr (seconds) (3))))), maxx - 34, maxy - 44, picCopy)

	elsif length (intstr (seconds)) > 3 then        %stops after 999 seconds
	    exit
	end if
	View.Update

	exit when gameover or newgame or player_win     %stops if player lost, player win, or new game
    end loop


    finaltime := seconds

end timer

%%%%%%%%%% ALERTS %%%%%%%%%%

procedure playagain                                     %play again button
    Window.Close (win_MINESWEEPER)
    newgame := true
    GUI.Quit
end playagain

procedure exitgame                                     %Exit game button
    Window.Close (win_MINESWEEPER)
    leave := true
    GUI.Quit
end exitgame

%%%%% Window popups
procedure winner (message : string)                     %Pops up if player WON
    win_WIN := Window.Open ("graphics:500;200, position:center,400, nooffscreenonly, nobuttonbar, title:WINNER")

    colourback (79)
    for background : 0 .. 40
	put repeat (" ", 20)
    end for
    Font.Draw (message, 50, 100, font_INTRO, 30)
    Font.Draw ("Time: ", maxx div 2 - 55, 70, font_TIME, 16)
    Font.Draw (intstr (finaltime), maxx div 2 + 15, 70, font_TIME, 16)            %finish time

    var hello : int := GUI.CreateButton (100, 40, 0, "Play again", playagain)     %newgame
    var bye : int := GUI.CreateButton (300, 40, 0, "Exit", exitgame)              %exit

    loop
	exit when GUI.ProcessEvent
    end loop
    GUI.ResetQuit
    Window.Close (win_WIN)                               %close alert window

end winner

procedure loser (message : string)                      %Pops up if player LOST
    win_LOSE := Window.Open ("graphics:500;200, position:center,400, nooffscreenonly, nobuttonbar, title:WINNER")

    colourback (79)
    for background : 0 .. 40
	put repeat (" ", 20)
    end for
    Font.Draw (message, 50, 100, font_INTRO, 30)


    var hello : int := GUI.CreateButton (100, 40, 0, "Play again", playagain)     %newgame
    var bye : int := GUI.CreateButton (300, 40, 0, "Exit", exitgame)             %exit

    loop
	exit when GUI.ProcessEvent
    end loop
    GUI.ResetQuit
    Window.Close (win_LOSE)                             %close alert window
end loser


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% MAIN CODE %%%%%%%%%%%%%%%               %(Continued - see MAIN CODE (INTRO))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loop
    GUI.ResetQuit
    if level1 = true then                               %Opens a window sized according to player's selected level
	win_MINESWEEPER := Window.Open ("graphics: 160;210, position: center,400, title: Minesweeper, nobuttonbar, offscreenonly")
    elsif level2 = true then
	win_MINESWEEPER := Window.Open ("graphics: 292;337, position: center,400, title: Minesweeper, nobuttonbar, offscreenonly")
    elsif level3 = true then
	win_MINESWEEPER := Window.Open ("graphics: 544;337, position: center,400, title: Minesweeper, nobuttonbar, offscreenonly")
    end if

    fork aud_THEME
    mapprep (size_x, size_y)                             %Setting up the game
    Draw.Cls                                             %resets all drawings from last round
    hide_mines
    mapdraw

    fork timer

    mouse_button_pressed := 0
    View.Update

    loop                                                  %game play loop
	mousewhere (mouse_x, mouse_y, mouse_button)
	mouse_area_x := (floor (mouse_x / cellsize_x))     %mouse grid on cells
	mouse_area_y := (floor (mouse_y / cellsize_y))


	if mouse_area_x < 1 or mouse_area_x > boardsize_x or mouse_area_y < 1 or mouse_area_y > boardsize_y then        %ignores clicks outside of gameboard
	    mouse_button := 0
	end if

	if mouse_button_pressed = 1 and mouse_button = 0 and player (mouse_area_x, mouse_area_y) = MOUSE_nothing then      % left-click = reveal square
	    player (mouse_area_x, mouse_area_y) := MOUSE_opened
	    mapdraw
	    View.Update

	    if cell (mouse_area_x, mouse_area_y) = minecell then                     %checks if minecell was clicked and player lost
		gameover := true
		death_reveal                                                        %reveals map when lost
		mapdraw
		Music.PlayFileStop
		fork aud_BOOM
		delay (3000)
		fork aud_LOSER
		loser ("YOU LOST!")                                                 %loser window
		Music.PlayFileStop
		View.Update
		exit


	    elsif cell (mouse_area_x, mouse_area_y) = mapempty then                 %checks if blank space was clicked
		empty_cells (mouse_area_x, mouse_area_y)
		mapdraw
		View.Update

	    elsif newgame = true then
		exit

	    else
		mapdraw
		View.Update
	    end if

	elsif mouse_button_pressed = 100 and mouse_button = 0 then                    %right-click = switch between none / flag / question
	    case player (mouse_area_x, mouse_area_y) of
		label MOUSE_nothing :
		    player (mouse_area_x, mouse_area_y) := MOUSE_flagged
		    minecount := minecount - 1
		label MOUSE_flagged :
		    player (mouse_area_x, mouse_area_y) := MOUSE_questionmark
		    minecount := minecount + 1
		label MOUSE_questionmark :
		    player (mouse_area_x, mouse_area_y) := MOUSE_nothing
		label MOUSE_opened :
	    end case

	    mapdraw
	    View.Update
	end if

	if player_win then                                                          %checks if board cleared and player won
	    delay (2000)
	    fork aud_WINNER
	    GUI.ResetQuit
	    winner ("YOU WIN!")                                                       %winner window
	    Music.PlayFileStop
	    View.Update
	    exit

	end if

	mouse_button_pressed := mouse_button

    end loop

    if leave then                                                                %exit button
	exit
    end if

    View.Update
    GUI.ResetQuit                                                               %all GUIs are now reusable
end loop
