a=[1;7;3]
b=[1;8;3]

result=0;

for i=1:min([size(a,1),size(b,1)])
	j=min([size(a,1),size(b,1)])-i+1
    if a(j)==b(j)
        result=j;
    end
end
result
find(a==b)