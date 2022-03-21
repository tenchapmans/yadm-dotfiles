-- ## Modules ## -------------------------------------------------------------------
import XMonad
import XMonad.Util.SpawnOnce
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers

import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps

import System.Exit
import Control.Monad
import Data.Monoid
import Data.Maybe

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- ## Startup hook ## ---------------------------------------------------------------
myStartupHook = do spawn "bash ~/.xmonad/bin/autostart.sh"

-- ## Settings ## -------------------------------------------------------------------

-- focus follows the mouse pointer
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- clicking on a window to focus
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels
myBorderWidth = 2

-- Border colors for focused & unfocused windows
myFocusedBorderColor = "#7daea3"
myNormalBorderColor = "#928374"

-- modMask : modkey you want to use
-- mod1Mask : left alt Key
-- mod4Mask : Windows or Super Key
myModMask = mod4Mask

-- Workspaces (ewmh)
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7"]

-- ## Key Bindings ## -------------------------------------------------------------------
myKeys conf@(XConfig {XMonad.modMask = super}) = M.fromList $

    -- Close focused window
    [ ((super, xK_c), kill)
    , ((super, xK_Escape), spawn "xkill")
    
    -- Change gaps on the fly
    , ((super .|. controlMask, xK_o), sendMessage $ IncGap 10 L)     -- increment the left-hand gap
    , ((super .|. shiftMask, xK_o), sendMessage $ DecGap 10 L)     -- decrement the left-hand gap
    
    , ((super .|. controlMask, xK_y), sendMessage $ IncGap 10 U)     -- increment the top gap
    , ((super .|. shiftMask, xK_y), sendMessage $ DecGap 10 U)     -- decrement the top gap
    
    , ((super .|. controlMask, xK_u), sendMessage $ IncGap 10 D)     -- increment the bottom gap
    , ((super .|. shiftMask, xK_u), sendMessage $ DecGap 10 D)     -- decrement the bottom gap

    , ((super .|. controlMask, xK_i), sendMessage $ IncGap 10 R)     -- increment the right-hand gap
    , ((super .|. shiftMask, xK_i), sendMessage $ DecGap 10 R)     -- decrement the right-hand gap

    -- Window Manager Specific -----------------------------------------

    -- Resize viewed windows to the correct size
    , ((super, xK_r), refresh)

    -- Move focus to the master window
    , ((super, xK_m), windows W.focusMaster)

    -- Push window back into tiling
    , ((super, xK_t), withFocused $ windows . W.sink)

    -- Rotate through the available layout algorithms
    , ((super, xK_space), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((super .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

    -- Move focus to the next window
    , ((super, xK_Tab), windows W.focusDown)

    -- Move focus to the next window
    , ((super, xK_j), windows W.focusDown)
    , ((super, xK_Left), windows W.focusDown)

    -- Move focus to the previous window
    , ((super, xK_k), windows W.focusUp)
    , ((super, xK_Right), windows W.focusUp)

    -- Swap the focused window with the next window
    , ((super .|. shiftMask, xK_j), windows W.swapDown)
    , ((super .|. shiftMask, xK_Left), windows W.swapDown)

    -- Swap the focused window with the previous window
    , ((super .|. shiftMask, xK_k), windows W.swapUp)
    , ((super .|. shiftMask, xK_Right), windows W.swapUp)

    -- Shrink the master area
    , ((super, xK_h), sendMessage Shrink)
    , ((super .|. controlMask, xK_Left), sendMessage Shrink)

    -- Expand the master area
    , ((super, xK_l), sendMessage Expand)
    , ((super .|. controlMask, xK_Right), sendMessage Expand)

    -- Increment the number of windows in the master area
    , ((super, xK_comma), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((super, xK_period), sendMessage (IncMasterN (-1)))

    -- Restart xmonad
    , ((controlMask .|. shiftMask, xK_r), spawn "xmonad --recompile; xmonad --restart")
    
    -- Quit xmonad
    , ((controlMask .|. shiftMask, xK_q), spawn "pkill -KILL -u $USER")

    ]
    ++

    -- Workspace Specific ---------------------------------------------------------------

    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. super, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1,xK_2,xK_3,xK_4,xK_5,xK_6,xK_7,xK_8,xK_9,xK_0]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    -- mod-{q,a,z}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{q,a,z}, Move client to screen 1, 2, or 3
    [((m .|. super, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_q, xK_a, xK_z] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

-- ## Mouse Bindings ## ------------------------------------------------------------------
myMouseBindings (XConfig {XMonad.modMask = super}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((super, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((super, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((super, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))
    ]

-- ## Layouts ## -------------------------------------------------------------------------
myLayout = avoidStruts(tiled ||| Mirror tiled ||| Full)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

-- ## Window rules ## --------------------------------------------------------------------
myManageHook = composeAll . concat $
    [ [isDialog --> doCenterFloat]
    , [className =? c --> doCenterFloat | c <- myCFloats]
    , [title =? t --> doCenterFloat | t <- myTFloats]
    , [resource =? r --> doFloat | r <- myRFloats]
    , [resource =? i --> doIgnore | i <- myIgnores]
    , [className =? "Alacritty" --> viewShift "1"]
    , [className =? "org.wezfurlong.wezterm" --> viewShift "1"]
    , [className =? "firefox" --> viewShift "2"]
    , [className =? "Thunar" --> viewShift "3"]
    , [className =? "Geany" --> viewShift "4"]
    , [className =? "code-oss" --> viewShift "4"]
    , [className =? "Inkscape" --> viewShift "5"]
    , [className =? "vlc" --> viewShift "6"]
    , [className =? "Xfce4-settings-manager" --> viewShift "7"]
    ]
    where
                viewShift = doF . liftM2 (.) W.greedyView W.shift
                myCFloats = ["Viewnior", "Alafloat"]
                myTFloats = ["Downloads", "Save As...", "Getting Started"]
                myRFloats = []
                myIgnores = ["desktop_window"]

-- ## Event handling ## -------------------------------------------------------------------
myEventHook = ewmhDesktopsEventHook

-- ## Logging ## --------------------------------------------------------------------------
myLogHook = return ()

-- ## Main Function ## --------------------------------------------------------------------

-- Run xmonad with all the configs we set up.
main = xmonad $ fullscreenSupport $ docks $ ewmh defaults

defaults = def {
      -- configs
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        manageHook         = myManageHook,
        layoutHook         = gaps [(L,0), (R,0), (U,45), (D,0)] $ spacingRaw False (Border 0 0 0 0) True (Border 0 0 0 0) True $ myLayout,
        handleEventHook    = myEventHook,
        logHook            = myLogHook,
        startupHook        = myStartupHook
    }
