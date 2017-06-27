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
        vl{1,1} = 'Run step 1,2,3,4 with inputs are PET and MRI images';
        vl{2,1} = 'Run step 5 with inputs are all processed images after coregister, segment, matching...';
        %explainStr{3,1} = 'Analyze stored SUV images, can specified SUV images or SUV.mat';
        vl{3,1} = 'Input location of PET, MRI image files and personal information parameters of patient: weight, dosage, time, half_life';
end
     