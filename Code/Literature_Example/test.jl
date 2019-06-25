using Printf

function get()
	a = 5
	a
end

for i in 1:100
	@time a = get()
	@printf "This is a test\n"
end
