#========================================================
# Custom CSS
#========================================================

ui_css <- HTML(

paste0(

"

/*======================================================
General
======================================================*/

body{

    background:", ui_colour("background"), ";

    color:", ui_colour("text"), ";

}


/*======================================================
Navbar
======================================================*/

.navbar{

    border:none;

    box-shadow:", ui_constant("shadow_sm"), ";

}


/*======================================================
Cards
======================================================*/

.card{

    border:none;

    border-radius:", ui_constant("radius_lg"), ";

    background:", ui_colour("card_background"), ";

    box-shadow:", ui_constant("shadow_md"), ";

    transition:", ui_constant("transition"), ";

}

.card:hover{

    transform:translateY(-2px);

    box-shadow:", ui_constant("shadow_lg"), ";

}


/*======================================================
Card Header
======================================================*/

.card-header{

    background:white;

    border-bottom:1px solid ", ui_colour("border"), ";

    font-weight:600;

}


/*======================================================
Metric Cards
======================================================*/

.metric-card{

    background:white;

    border-radius:16px;

    padding:20px;

    min-height:125px;

    box-shadow:0 3px 12px rgba(0,0,0,.05);

    transition:all .2s ease;

}

.metric-card:hover{

    transform:translateY(-2px);

    box-shadow:0 8px 20px rgba(0,0,0,.08);

}

.metric-top{

    display:flex;

    justify-content:space-between;

    align-items:flex-start;

}

.metric-left{

    display:flex;

    flex-direction:column;

    gap:8px;

}

.metric-icon{

    font-size:1.3rem;

    color:#2563EB;

}

.metric-title{

    font-size:.9rem;

    font-weight:600;

    color:#6B7280;

}

.metric-value{

    font-size:2.4rem;

    font-weight:700;

    line-height:1;

}

.metric-subtitle{

    margin-top:14px;

    font-size:.85rem;

    color:#6B7280;

}


/*======================================================
Buttons
======================================================*/

.btn{

    border-radius:", ui_constant("radius_md"), ";

    transition:", ui_constant("transition"), ";

}

.btn:hover{

    transform:translateY(-1px);

}


/*======================================================
DataTables
======================================================*/

table.dataTable{

    border-collapse:collapse !important;

}

table.dataTable thead{

    background:", ui_colour("background"), ";

}

table.dataTable thead th{

    border-bottom:1px solid ", ui_colour("border"), ";

    color:", ui_colour("text_muted"), ";

    font-weight:600;

}

table.dataTable tbody tr{

    transition:", ui_constant("transition"), ";

}

table.dataTable tbody tr:hover{

    background:#F9FAFB;

}


/*======================================================
Badges
======================================================*/

.status-ready{

    color:white;

    background:", ui_colour("ready"), ";

}

.status-open{

    color:white;

    background:", ui_colour("open"), ";

}

.status-watching{

    color:white;

    background:", ui_colour("watching"), ";

}

.status-closed{

    color:white;

    background:", ui_colour("closed"), ";

}


/*======================================================
Scrollbar
======================================================*/

::-webkit-scrollbar{

    width:8px;

}

::-webkit-scrollbar-thumb{

    background:#CBD5E1;

    border-radius:20px;

}


/*======================================================
Animations
======================================================*/

.fade-in{

    animation:fadeIn .30s ease;

}

@keyframes fadeIn{

from{

    opacity:0;

    transform:translateY(6px);

}

to{

    opacity:1;

    transform:none;

}

}

"

)

)