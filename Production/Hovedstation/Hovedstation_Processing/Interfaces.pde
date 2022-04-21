//MouseHover.checkMouseHover(origoX, origoY, componentWidth, componentHeight, mouseX, mouseY)
interface MouseHover {
    public static boolean checkMouseHover(int origoX, int origoY, int componentWidth, int componentHeight, int mouseXpos, int mouseYpos) {
        if (mouseXpos >= origoX && mouseXpos <= origoX + componentWidth && 
            mouseYpos >= origoY && mouseYpos <= origoY + componentHeight) {
            return true;
        } else {
            return false;
        }
    }
}
