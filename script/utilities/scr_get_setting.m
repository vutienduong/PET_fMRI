function vl = scr_get_setting(kw)
switch(kw)
    case 'global_setting'
        vl = 'global_setting.txt';
    case 'explain_method_new_old'
        vl = cell(1);
        epl_val1 = cell(1); 
        epl_val1{1,1} = 'Step 1: Coregister PET to MRI -> rPET,';
        epl_val1{2,1} = 'Step 2: Segment MRI -> WM, GM ....';
        epl_val1{3,1} = 'Step 3: Matching WM to rPET -> m_rPET ...';
        epl_val1{4,1} = 'Step 4: Inversely normalizing AAL temp to MRI -> rROI_MNI_V4';

        epl_val2 = cell(1); 
        epl_val2{1,1} = 'Step 1: Coregister PET to MRI along with AAL -> rPET, rAAL,';
        epl_val2{2,1} = 'Step 2: Segment MRI -> WM, GM ....';
        epl_val2{3,1} = 'Step 3: Matching WM to rPET -> m_rPET ...';
        epl_val2{4,1} = 'Step 4: Coregister rAAL temp to MRI -> rrAAL';
        
        vl{1,1} = epl_val1;
        vl{2,1} = epl_val2;
    case 'explain_opt_main_menu'
        vl = cell(1);
        vl{1,1} = '(Multi subjects) I. Create ''WM extracted'' images from multiple PET, MRI images';
        vl{2,1} = '(Multi subjects) II. Calculate SUV, SUVR, VOLUME from ''WM extracted'' images created in step I.';
        vl{3,1} = '(One subject) Calculate SUV, SUVR, VOLUME from a pair PET-MRI of a subject';
end
     