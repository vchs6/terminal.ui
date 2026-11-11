/* Private GTK fixture module. Reads actual VTE state; never consumes ANSI. */
#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
typedef unsigned long Type;
typedef struct List {void *data;struct List *next,*prev;} List;
static void *terminal;
static const char *dir;
static const char *widget_type;
static char current_path[2048],widget_path[2048];
static int candidates;
#define FN(name,ret,args) static ret (*name) args
FN(g_type_check_instance_is_a,int,(void*,Type));
FN(g_type_name_from_instance,const char*,(void*));
FN(gtk_container_get_type,Type,(void));
FN(vte_terminal_get_type,Type,(void));
FN(gtk_container_foreach,void,(void*,void(*)(void*,void*),void*));
FN(gtk_window_list_toplevels,List*,(void));
FN(g_list_free,void,(List*));
FN(g_free,void,(void*));
FN(g_timeout_add,unsigned,(unsigned,int(*)(void*),void*));
FN(vte_terminal_get_row_count,long,(void*));
FN(vte_terminal_get_column_count,long,(void*));
FN(vte_terminal_get_cursor_position,void,(void*,long*,long*));
FN(vte_terminal_get_text,char*,(void*,void*,void*,void*));
FN(vte_terminal_get_text_range,char*,(void*,long,long,long,long,void*,void*,void*));
FN(gtk_scrollable_get_vadjustment,void*,(void*));
FN(gtk_adjustment_get_value,double,(void*));
FN(gtk_adjustment_get_lower,double,(void*));
FN(gtk_adjustment_get_upper,double,(void*));
FN(gtk_adjustment_get_page_size,double,(void*));
FN(g_file_new_for_path,void*,(const char*));
FN(g_file_replace,void*,(void*,const char*,int,int,void*,void**));
FN(g_output_stream_close,int,(void*,void*,void**));
FN(g_object_unref,void,(void*));
FN(vte_terminal_write_contents_sync,int,(void*,void*,int,void*,void**));
static void visit(void *widget,void *unused) {
    (void)unused;
    size_t length=strlen(current_path);
    const char *name=g_type_name_from_instance(widget);
    if(length+strlen(name)+2>=sizeof(current_path))abort();
    strcat(current_path,"/");strcat(current_path,name);
    if(g_type_check_instance_is_a(widget,vte_terminal_get_type())){terminal=widget;widget_type=name;strcpy(widget_path,current_path);candidates++;}
    else if(g_type_check_instance_is_a(widget,gtk_container_get_type()))gtk_container_foreach(widget,visit,NULL);
    current_path[length]='\0';
}
static void save(const char *path,const char *text) {
    FILE *out=fopen(path,"wb");if(!out)abort();
    if(text)fwrite(text,1,strlen(text),out);fclose(out);
}
static int poll(void *unused) {
    (void)unused;char request[4096],path[4096];
    snprintf(request,sizeof(request),"%s/native-request",dir);
    FILE *in=fopen(request,"r");if(!in)return 1;
    int index=-1;if(fscanf(in,"%d",&index)!=1||index<0||index>9)abort();fclose(in);
    List *list=gtk_window_list_toplevels();terminal=NULL;candidates=0;current_path[0]='\0';
    for(List *p=list;p;p=p->next)visit(p->data,NULL);g_list_free(list);
    if(!terminal)return 1;
    if(candidates!=1)abort();
    long rows=vte_terminal_get_row_count(terminal),cols=vte_terminal_get_column_count(terminal),cx,cy;
    vte_terminal_get_cursor_position(terminal,&cx,&cy);
    void *adjustment=gtk_scrollable_get_vadjustment(terminal);
    double top=gtk_adjustment_get_value(adjustment);
    char *text=vte_terminal_get_text(terminal,NULL,NULL,NULL);
    snprintf(path,sizeof(path),"%s/native-%d-visible.txt",dir,index);save(path,text);g_free(text);
    text=vte_terminal_get_text_range(terminal,(long)top,0,(long)top+rows-1,cols-1,NULL,NULL,NULL);
    snprintf(path,sizeof(path),"%s/native-%d-range.txt",dir,index);save(path,text);g_free(text);
    for(long row=0;row<rows;row++){
        text=vte_terminal_get_text_range(terminal,(long)top+row,0,(long)top+row,cols-1,NULL,NULL,NULL);
        snprintf(path,sizeof(path),"%s/native-%d-row-%ld.txt",dir,index,row);save(path,text);g_free(text);
    }
    snprintf(path,sizeof(path),"%s/native-%d-contents.txt",dir,index);
    void *file=g_file_new_for_path(path),*error=NULL;
    void *stream=g_file_replace(file,NULL,0,1,NULL,&error);
    int result=stream?vte_terminal_write_contents_sync(terminal,stream,0,NULL,&error):0;
    int closed=stream?g_output_stream_close(stream,NULL,&error):0;
    if(stream)g_object_unref(stream);g_object_unref(file);
    snprintf(path,sizeof(path),"%s/native-%d-meta.json",dir,index);FILE *out=fopen(path,"w");
    time_t now=time(NULL);struct tm utc;char stamp[32];gmtime_r(&now,&utc);strftime(stamp,sizeof(stamp),"%Y-%m-%dT%H:%M:%SZ",&utc);
    fprintf(out,"{\"utc\":\"%s\",\"widgetPath\":\"%s\",\"candidateCount\":%d,",stamp,widget_path,candidates);
    fprintf(out,"\"index\":%d,\"pid\":%ld,\"widgetType\":\"%s\",\"widgetDiscovery\":\"gtk_window_list_toplevels -> gtk_container_foreach recursively -> g_type_check_instance_is_a(vte_terminal_get_type)\",\"rows\":%ld,\"cols\":%ld,\"cursorCol\":%ld,\"cursorRow\":%ld,\"top\":%.0f,\"lower\":%.0f,\"upper\":%.0f,\"pageSize\":%.0f,\"writeContentsResult\":%d,\"streamCloseResult\":%d,\"errorPresent\":%s}\n",index,(long)getpid(),widget_type,rows,cols,cx,cy,top,gtk_adjustment_get_lower(adjustment),gtk_adjustment_get_upper(adjustment),gtk_adjustment_get_page_size(adjustment),result,closed,error?"true":"false");fclose(out);
    unlink(request);return 1;
}
void gtk_module_init(int *argc,char ***argv) {
    (void)argc;(void)argv;dir=getenv("VTE_NATIVE_CAPTURE_DIR");if(!dir)abort();
#define LOAD(name) do { *(void **)(&name)=dlsym(RTLD_DEFAULT,#name);if(!name){fprintf(stderr,"native fixture missing %s\n",#name);abort();}}while(0)
    LOAD(g_type_check_instance_is_a);LOAD(g_type_name_from_instance);LOAD(gtk_container_get_type);LOAD(vte_terminal_get_type);
    LOAD(gtk_container_foreach);LOAD(gtk_window_list_toplevels);LOAD(g_list_free);LOAD(g_free);LOAD(g_timeout_add);
    LOAD(vte_terminal_get_row_count);LOAD(vte_terminal_get_column_count);LOAD(vte_terminal_get_cursor_position);
    LOAD(vte_terminal_get_text);LOAD(vte_terminal_get_text_range);LOAD(gtk_scrollable_get_vadjustment);
    LOAD(gtk_adjustment_get_value);LOAD(gtk_adjustment_get_lower);LOAD(gtk_adjustment_get_upper);LOAD(gtk_adjustment_get_page_size);
    LOAD(g_file_new_for_path);LOAD(g_file_replace);LOAD(g_output_stream_close);LOAD(g_object_unref);LOAD(vte_terminal_write_contents_sync);
    g_timeout_add(30,poll,NULL);
}
