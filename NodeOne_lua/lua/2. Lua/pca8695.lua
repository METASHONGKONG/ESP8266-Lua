
local modname = ...
local M = {}
_G[modname] = M

local id = nil
local addr = nil

-- some flags from mode register, low byte is MODE1 and high is MODE2
M.INVERT = 0x1000

local function read_reg(reg)--read  data
	i2c.start(id)
	if not i2c.address(id, addr, i2c.TRANSMITTER) then
		return nil
	end
	i2c.write(id, reg)
	i2c.stop(id)
	i2c.start(id)
	if not i2c.address(id, addr, i2c.RECEIVER) then
		return nil
	end
	c = i2c.read(id, 1)
	i2c.stop(id)
	return c:byte(1)
end

local function write_reg(reg, ...)--write data
	i2c.start(id)
	if not i2c.address(id, addr, i2c.TRANSMITTER) then
		return nil
	end
	i2c.write(id, reg)
	len = i2c.write(id, ...)
	i2c.stop(id)
	return len
end

local function chan_reg(chan, reg)
	return 6 + chan*4 + reg;
end

function M.init(i2c_id, i2c_addr, mode)--RGB init
	id = i2c_id
	addr = i2c_addr
	if write_reg(0, bit.bor(0x21, bit.band(mode, 0xFF))) ~= 1 then
		return nil
	end
	if write_reg(1, bit.bor(0x04, bit.band(bit.rshift(mode, 8), 0xFF))) ~= 1 then
		return nil
	end
end

function M.set_chan_on(chan, on)-- choose chan on
	return write_reg(chan_reg(chan, 1), 0x10 * on)
end

function M.set_chan_off(chan, off)--choose chan off
	return write_reg(chan_reg(chan, 3), 0x10 * off)
end

function M.set_chan_pwm(chan, on, off)
	return write_reg(chan_reg(chan, 0), bit.band(on, 0xFF), bit.rshift(on, 8), bit.band(off, 0xFF), bit.rshift(off, 8))
end

function M.set_chan_percent(chan, val)--调节chan百分比
	if (val < 0) or (val > 100) then
		return nil
	end
	if val == 0 then
		M.set_chan_on(chan, 0)
		M.set_chan_off(chan, 1)
	elseif val == 100 then
		M.set_chan_on(chan, 1)
		M.set_chan_off(chan, 0)
	else
		M.set_chan_pwm(chan, 0, 4096*val/100)
	end
end

return M