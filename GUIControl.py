import streamlit as st
from util import *

st.set_page_config(
# 	layout="centered",  # Can be "centered" or "wide". In the future also "dashboard", etc.
# 	initial_sidebar_state="auto",  # Can be "auto", "expanded", "collapsed"
 	page_title="VR on GoogleEarth",  # String or None. Strings get appended with "• Streamlit". 
# 	page_icon=None,  # String, anything supported by st.image, or None.
)

st.markdown(
    """
    <style>
    .main {
    background-color: #ddeeff;
    }
    </style>
    """,
    unsafe_allow_html=True
)

COMM_PATH = 'resources/public/comm/command.fct'
NAMES_PATH = 'resources/public/chart/fleet.txt'

if 'cam_hdg' not in st.session_state:
    st.session_state.cam_hdg = 0
if 'cam_alt' not in st.session_state:
    st.session_state.cam_alt = 0
if 'alt_factor' not in st.session_state:
    st.session_state.alt_factor = 1
if 'cam_tilt' not in st.session_state:
    st.session_state.cam_tilt = 80
if 'cam_rng' not in st.session_state:
    st.session_state.cam_rng = 100
if 'names' not in st.session_state:
    st.session_state.names = []
if 'onb_boat' not in st.session_state:
    st.session_state.onb_boat = 'russor'


st.title(':blue[Virtual Regatta on Google Earth]')

st.header(':green[Look at]')

cam_hdg = st.slider("Heading", -180, 180, 0, step=10, key='view')
if cam_hdg != st.session_state.cam_hdg:
    st.session_state.cam_hdg = cam_hdg
    save_file(COMM_PATH, '(Command kml-cam-hdg '+str(cam_hdg)+')')

c1, c2 = st.columns(2)
with c1:
    alt_factor = st.session_state.alt_factor
    cam_alt = st.slider("Altitude", 0, 40, 2, step=2, key='camalt')
    if cam_alt != st.session_state.cam_alt:
        st.session_state.cam_alt = cam_alt
        save_file(COMM_PATH, '(Command kml-cam-alt '+str(cam_alt * alt_factor)+')')
        
with c2:
    alt_factor = st.selectbox("Altitude factor", [1, 10, 100, 1000, 10000],  key='altfac')
    if alt_factor != st.session_state.alt_factor:
        st.session_state.alt_factor = alt_factor
        save_file(COMM_PATH, '(Command kml-cam-alt '+str(cam_alt * alt_factor)+')')
    
cam_tilt = st.slider("Tilt", 0, 90, 80, step=10, key='camtilt')
if cam_tilt != st.session_state.cam_tilt:
    st.session_state.cam_tilt = cam_tilt
    save_file(COMM_PATH, '(Command kml-cam_tilt '+str(cam_tilt)+')')
    
cam_rng = st.slider("Range", 0, 200, 100, step=10, key='camrng')
if cam_rng != st.session_state.cam_rng:
    st.session_state.cam_rng = cam_rng
    save_file(COMM_PATH, '(Command kml-cam_rng '+str(cam_rng)+')')
    
def load_boats():
    names = load_names(NAMES_PATH)
    names.sort()
    st.session_state.names = names
    
def go_onboard():
    onb_boat = st.session_state.onb_boat
    save_file(COMM_PATH, '(Command on-board "'+onb_boat+'")')    

c3, c4, c5 = st.columns([1, 4, 1])
with c3:
    st.button('Load boats', on_click=load_boats)

with c4:
    st.session_state.onb_boat = st.selectbox("Select boat", st.session_state.names,  key='bnam')

with c5:
    st.button('Go on board', on_click=go_onboard)

    
    