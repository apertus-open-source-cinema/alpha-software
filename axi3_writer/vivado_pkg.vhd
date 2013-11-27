----------------------------------------------------------------------------
--  vivado_pkg.vhd
--	Vivado Specific Attributes
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

package vivado_pkg is

    attribute BUFFER_TYPE : string;

    --  Apply BUFFER_TYPE on an input to describe what type of buffer 
    --  to use.
    --
    --  By default, Vivado synthesis uses IBUF/BUFG or BUFGPs
    --  for clocks and IBUFs for inputs.
    --
    --  Supported values are:
    --  - ibuf : For clock ports where a IBUF/BUFG pair is
    --  	 not wanted. In this case only, the IBUF
    --  	 is inferred for the clock.
    --
    --  - none : Indicates that no input or output buffers
    --  	 are used. A none value on a clock port
    --  	 results in no buffers.
    --
    --  The BUFFER_TYPE attribute can be placed on any top-level port.


    attribute MAX_FANOUT : integer;

    --  MAX_FANOUT instructs Vivado synthesis on the fanout limits
    --  for registers and signals. You can specify this either in
    --  RTL or as an input to the project. The value is an integer.
    --
    --  This attribute only works on registers and combinatorial
    --  signals. To achieve the fanout, it replicates the register
    --  or the driver that drives the combinatorial signal.


    attribute KEEP_HIERARCHY : string;

    --  KEEP_HIERARCHY is used to prevent optimizations along the
    --  hierarchy boundaries. The Vivado synthesis tool attempts to
    --  keep the same general hierarchies specified in the RTL, but
    --  for QoR reasons it can flatten or modify them.
    --
    --  If KEEP_HIERARCHY is placed on the instance, the synthesis
    --  tool keeps the boundary on that level static.
    --  This can affect QoR and also should not be used on modules
    --  that describe the control logic of 3-state outputs and I/O
    --  buffers.
    --
    --  The KEEP_HIERARCHY can be placed in the module or 
    --  architecture level or the instance.


    attribute DONT_TOUCH : string;

    --  Use the DONT_TOUCH attribute in place of KEEP or KEEP_HIERARCHY.
    --  The DONT_TOUCH works in the same way as KEEP or KEEP_HIERARCHY
    --  attributes; however, unlike KEEP and KEEP_HIERARCHY, DONT_TOUCH
    --  is forward-annotated to place and route to prevent logic
    --  optimization.
    --
    --  Like KEEP and KEEP_HIERARCHY, be careful when using DONT_TOUCH.
    --  In cases where other attributes are in conflict with DONT_TOUCH,
    --  the DONT_TOUCH attribute takes precedence.
    --
    --  The values for DONT_TOUCH are TRUE/FALSE or yes/no. 
    --  This attribute can be placed on any signal, module, entity,
    --  or component.


    attribute MARK_DEBUG : string;

    --  Set MARK_DEBUG on a net in the RTL to preserve it and make 
    --  it visible in the netlist.
    --
    --  This allows it to be connected to the logic debug tools at 
    --  any point in the compilation flow.


    attribute REGISTER_BALANCING : string;

    --  YES, NO, FORWARD, BACKWARD


    attribute REGISTER_DUPLICATION : string;

    --  YES, NO

end package;

package body vivado_pkg is

end package body;
