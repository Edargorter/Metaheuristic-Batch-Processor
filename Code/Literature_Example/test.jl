using Printf

function get(instr::Int, mi::Int, ma::Int)
	instr = (instr + ma - mi) % (ma - mi + 1)
end

a = get(2, 0, 3)
@printf "%d\n" a

a = Dict{Int, Int}()
a[1] = 2
a[3] = 4

print(a)

for (ind, val) in a
	@printf "Ind %d Val %d\n" ind val
end
