
function x=build_gephi_files()

x=1;

A=dlmread('C:/Users/cyber_000/Documents/Dropbox/Harvard/Job Placement/CID/Projects/Other/Gephi Workshop2/flow.txt'); % read flow.txt and name it A

[r c]=find(A); % returns the row and column subscripts of each nonzero element in array A
for i=1:size(r,1)  % for values i=1 until the number of rows (r) of A
    A(r(i),c(i))=1-A(r(i),c(i)); % replace the i,i position of A with 1-i,i position of A.
end

%el MST coge lo mínimo, es decir menor es mejor. Luego lo mayor debe ser lo menor y por eso la transformación. Bien?

% matlab funcion for MST 
AAA=graphminspantree(sparse(A)); % encuentra el MST de(de la matriz A quitándole los ceros {los ceros ocurren cuando ind_i=ind_j entonces bien.})

% make full matrix as lower triangular
AAA=AAA+AAA'; % why do we need this?
AAA=full(AAA); % convert to full storage

[r c]=find(AAA);
for i=1:size(r,1)
    AAA(r(i),c(i))=1-AAA(r(i),c(i));  % esto pondría en unos el triángulo superior no? Para qué necesito esto? No entiendo bien
end

% find MST of positive values
dlmwrite('C:/Users/cyber_000/Documents/Dropbox/Harvard/Job Placement/CID/Projects/Other/Gephi Workshop2/simi_mst_flow.txt',AAA) % exporte como simi_mst_flow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
