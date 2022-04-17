function noDataReturn = saveFileDisk(name,variable)

    savename = sprintf('%s',inputname(2));

    S.(savename) = variable;

    %save(['_WorkData/' name '.mat'], '-struct', 'S', savename);
    save([name '.mat'], '-struct', 'S', savename);

    noDataReturn = 'file saved';

end