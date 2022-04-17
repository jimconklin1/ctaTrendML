function out = monthJC(DATE,opt)
bob=datestr(DATE,23);
if opt
    out1=str2num(bob(:,[1 2])); %#ok<ST2NM>
    out2=bob(:,[1 2]);
    out=[{out1} {out2}];
else
    out=str2num(bob(:,[1 2])); %#ok<ST2NM>
end