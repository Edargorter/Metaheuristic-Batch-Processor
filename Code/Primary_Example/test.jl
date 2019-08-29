using Printf

struct unit
	a::Array{Int}
	b::Array{Int}
end

function get_unit()
	a = [rand(1:100), rand(1:100), rand(1:100)]
	b = [rand(1:100), rand(1:100), rand(1:100)]
	unit(a, b)
end

function testfunc()
	units = []

	a = [1,2,3]
	b = [4,5,6]
	push!(units, unit(a, b))	
	a = [10, 20, 30]
	b = [40, 50, 60]
	push!(units, unit(a, b))
	
	for i in 1:2
		Un::unit = get_unit()
		units[i] = Un
	end
	
	print(units)
end

testfunc()
