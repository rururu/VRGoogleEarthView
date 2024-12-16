import streamlit as st
import os
from util import *

st.set_page_config(
# layout="centered",  # Can be "centered" or "wide". In the future also "dashboard", etc.
# initial_sidebar_state="auto",  # Can be "auto", "expanded", "collapsed"
     page_title="VR on GoogleEarth",  # String or None. Strings get appended with "• Streamlit". 
# page_icon=None,  # String, anything supported by st.image, or None.
    initial_sidebar_state="collapsed"
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

NAMES_PATH = 'resources/public/chart/fleet.txt'

if 'cam_hdg' not in st.session_state:
    st.session_state.cam_hdg = 0
if 'cam_alt' not in st.session_state:
    st.session_state.cam_alt = 4
if 'alt_factor' not in st.session_state:
    st.session_state.alt_factor = 1
if 'cam_tilt' not in st.session_state:
    st.session_state.cam_tilt = 90
if 'cam_rng' not in st.session_state:
    st.session_state.cam_rng = 100
if 'names' not in st.session_state:
    st.session_state.names = []
if 'onb_boat' not in st.session_state:
    st.session_state.onb_boat = 'russor'

st.title(':blue[Virtual Regatta on Google Earth]')

with st.sidebar:
    st.header(':violet[System Control]')

    data = ''

    cmd = st.text_input('Command', value='')
            
    if st.button('Execute Command'):
        data = send_cmd(cmd)

    ta = st.text_area('System Messages', data, height=500)
    
    c1, c2 = st.columns(2)
    with c1:
        if st.button('Restart Control'):
            save_file(CMD_PATH, '')
            save_file(CMD_PATH, '')
    with c2:
        if st.button('Restart CLIPS'):
            send_cmd('(exit-CLIPS)')
            save_file(CMD_PATH, '')
            if os.name == 'nt':
                os.system('run_CLP.bat')
            else:
                os.system('./run_CLP.sh &')

st.header(':green[Look At]')

cam_hdg = st.slider("Heading", -180, 180, 0, step=10, key='view')
if cam_hdg != st.session_state.cam_hdg:
    st.session_state.cam_hdg = cam_hdg
    send_cmd('(assert (Kml-cam-hdg '+str(cam_hdg)+'))')

c1, c2 = st.columns(2)
with c1:
    alt_factor = st.session_state.alt_factor
    cam_alt = st.slider("Altitude", 0, 40, 4, step=2, key='camalt')
    if cam_alt != st.session_state.cam_alt:
        st.session_state.cam_alt = cam_alt
        send_cmd('(assert (Kml-cam-alt '+str(cam_alt * alt_factor)+'))')
        
with c2:
    alt_factor = st.selectbox("Altitude factor", [1, 10, 100, 1000, 10000],  key='altfac')
    if alt_factor != st.session_state.alt_factor:
        st.session_state.alt_factor = alt_factor
        send_cmd('(assert (Kml-cam-alt '+str(cam_alt * alt_factor)+'))')
    
cam_tilt = st.slider("Tilt", 0, 90, 90, step=10, key='camtilt')
if cam_tilt != st.session_state.cam_tilt:
    st.session_state.cam_tilt = cam_tilt
    send_cmd('(assert (Kml-cam_tilt '+str(cam_tilt)+'))')
    
cam_rng = st.slider("Range", 0, 200, 100, step=10, key='camrng')
if cam_rng != st.session_state.cam_rng:
    st.session_state.cam_rng = cam_rng
    send_cmd('(assert (Kml-cam_rng '+str(cam_rng)+'))')
    
def load_boats():
    names = line_list(NAMES_PATH)
    names.sort()
    st.session_state.names = names
    
def go_onboard():
    onb_boat = st.session_state.onb_boat
    send_cmd('(assert (On-board ~'+onb_boat+'~))')
    
c3, c4, c5 = st.columns([1, 4, 1])
with c3:
    st.button('Load boats', on_click=load_boats)

with c4:
    st.session_state.onb_boat = st.selectbox("Select boat", st.session_state.names,  key='bnam')

with c5:
    st.button('Go on board', on_click=go_onboard)
    
st.divider()
    
def exit_func():
    send_cmd('(exit-CLIPS)')
    
c6, c7 = st.columns([5, 1])
with c6:
    st.warning('Do click this button before closing other windows!', icon="⚠️")
with c7:
    st.button('Exit', on_click=exit_func)
    
