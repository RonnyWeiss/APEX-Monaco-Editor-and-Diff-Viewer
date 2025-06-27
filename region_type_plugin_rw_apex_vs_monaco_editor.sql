prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.10.15'
,p_release=>'21.2.5'
,p_default_workspace_id=>100000
,p_default_application_id=>108
,p_default_id_offset=>0
,p_default_owner=>'RONNY'
);
end;
/
 
prompt APPLICATION 108 - Monaco Editor
--
-- Application Export:
--   Application:     108
--   Name:            Monaco Editor
--   Date and Time:   08:08 Friday June 27, 2025
--   Exported By:     RONNY
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 30127016042927264490
--   Manifest End
--   Version:         21.2.5
--   Instance ID:     900134127207897
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/rw_apex_vs_monaco_editor
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(30127016042927264490)
,p_plugin_type=>'REGION TYPE'
,p_name=>'RW.APEX.VS.MONACO.EDITOR'
,p_display_name=>'APEX-VS-Monaco-Editor'
,p_supported_ui_types=>'DESKTOP'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'function sql_to_sys_refcursor (',
'    p_in_sql_statement clob,',
'    p_in_binds         sys.dbms_sql.varchar2_table',
') return sys_refcursor as',
'    l_curs       binary_integer;',
'    l_ref_cursor sys_refcursor;',
'    l_exec       binary_integer;',
'    -- TODO make size dynamic',
'    l_binds      varchar(100);',
'begin',
'    l_curs       := dbms_sql.open_cursor;',
'    dbms_sql.parse(l_curs, p_in_sql_statement, dbms_sql.native);',
'',
'    if p_in_binds.count > 0 then',
'        for i in 1..p_in_binds.count loop',
'            -- TODO find out how to prevent ltrim',
'            l_binds := ltrim(p_in_binds(i), '':'');',
'            dbms_sql.bind_variable(l_curs, l_binds, v(l_binds));',
'        end loop;',
'    end if;',
'',
'    l_exec       := dbms_sql.execute(l_curs);',
'    l_ref_cursor := dbms_sql.to_refcursor(l_curs);',
'    return l_ref_cursor;',
'exception',
'    when others then',
'        if dbms_sql.is_open(l_curs) then',
'            dbms_sql.close_cursor(l_curs);',
'        end if;',
'        raise;',
'end;',
'',
'procedure store_clob (',
'    p_in_plsql_block clob,',
'    p_in_clob        clob',
') as',
'',
'    l_exec    binary_integer;',
'    l_tmp_str varchar2(32767) := null;',
'    l_curs    binary_integer;',
'    l_binds   varchar(100);',
'    l_binds_t sys.dbms_sql.varchar2_table := wwv_flow_utilities.get_binds(p_in_plsql_block);',
'begin',
'    l_curs := dbms_sql.open_cursor;',
'    dbms_sql.parse(l_curs, p_in_plsql_block, dbms_sql.native);',
'',
'    for i in 1..l_binds_t.count loop',
'        -- TODO find out how to prevent ltrim',
'        l_binds := ltrim(l_binds_t(i),'':'');',
'        case l_binds',
'            when ''CLOB'' then',
'                dbms_sql.bind_variable(l_curs, l_binds, p_in_clob);',
'            else',
'                -- get values for APEX items',
'                dbms_sql.bind_variable(l_curs, l_binds, v(l_binds));',
'        end case;',
'',
'    end loop;',
'',
'    l_exec := dbms_sql.execute(l_curs);',
'exception',
'    when others then',
'        if dbms_sql.is_open(l_curs) then',
'            dbms_sql.close_cursor(l_curs);',
'        end if;',
'        apex_debug.error(''APEX-VS-Monaco-Editor - Error while executing dynamic PL/SQL Block after Upload CLOB.'');',
'        apex_debug.error(sqlerrm);',
'        apex_debug.error(dbms_utility.format_error_backtrace);',
'        raise;',
'end;',
'',
'function f_ajax (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin',
') return apex_plugin.t_region_ajax_result is',
'',
'    l_function_type     constant varchar2(100) := apex_application.g_x01;',
'    l_plsql_upload_clob constant p_region.attribute_02%type := p_region.attribute_02;',
'    l_result            apex_plugin.t_region_ajax_result;',
'    l_cur               sys_refcursor;',
'    l_bind_names        sys.dbms_sql.varchar2_table;',
'    l_clob              clob := null;',
'    l_tmp_str           varchar2(32767);',
'begin',
'    if l_function_type = ''POST'' then',
'        begin',
'            dbms_lob.createtemporary(l_clob, false, dbms_lob.call);',
'            for i in 1..apex_application.g_f01.count loop',
'                l_tmp_str := wwv_flow.g_f01(i);',
'                if dbms_lob.getlength(l_tmp_str) > 0 then',
'                    dbms_lob.writeappend(l_clob, dbms_lob.getlength(l_tmp_str), l_tmp_str);',
'                end if;',
'',
'            end loop;',
'',
'            store_clob (',
'                p_in_plsql_block => l_plsql_upload_clob,',
'                p_in_clob        => l_clob',
'            );',
'',
'            apex_debug.info(''APEX-VS-Monaco-Editor - Upload and Execute of Dynamic PL/SQL Block successful with CLOB: '' ||',
'            dbms_lob.getlength(l_clob) || '' Bytes.'');',
'            apex_json.open_object;',
'            apex_json.write(p_name => ''result'', p_value => ''ok'');',
'            apex_json.close_object;',
'            dbms_lob.freetemporary(l_clob);',
'        exception',
'            when others then',
'                dbms_lob.freetemporary(l_clob);',
'                apex_debug.error(''APEX-VS-Monaco-Editor - Error while upload clob'');',
'                apex_debug.error(sqlerrm);',
'                apex_debug.error(dbms_utility.format_error_backtrace);',
'                raise;',
'        end;',
'    else',
'        -- undocumented function of APEX for get all bindings',
'        l_bind_names := wwv_flow_utilities.get_binds(p_region.source);',
'',
'        -- execute binding',
'        l_cur        := sql_to_sys_refcursor(rtrim(p_region.source, '';''), l_bind_names);',
'',
'        -- create json',
'        apex_json.open_object;',
'        apex_json.write(''rows'', l_cur);',
'        apex_json.close_object;',
'    end if;',
'',
'    return l_result;',
'end;',
'',
'function f_render (',
'    p_region              in apex_plugin.t_region,',
'    p_plugin              in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean',
') return apex_plugin.t_region_render_result as',
'',
'    -- Render result variable needed for return',
'    l_render_result  apex_plugin.t_region_render_result;',
'    l_base_url       varchar2(32767);',
'    -- static if of the chart region (should be escaped for security)',
'    c_static_id      constant varchar2(32767) := apex_escape.html_attribute(p_region.static_id) ||',
'    ''-container'';',
'    c_refresh_id     constant varchar2(32767) := apex_escape.html_attribute(p_region.static_id);',
'    -- list of items that should be submitted',
'    c_items2submit   constant apex_application_page_regions.ajax_items_to_submit%type := apex_plugin_util.page_item_names_to_jquery(p_region.ajax_items_to_submit);',
'begin',
'    apex_javascript.add_requirejs;',
'',
'    -- add script files (your javascript)',
'    apex_javascript.add_library(',
'        p_name => ''script'',',
'        p_directory => p_plugin.file_prefix,',
'        p_version => null,',
'        p_check_to_add_minified => true,',
'        p_key => ''vsmonacoeditorjssrc''',
'    );',
'',
'    if p_plugin.attribute_01 = ''Y'' then',
'        l_base_url := rtrim(p_plugin.attribute_02);',
'    elsif p_plugin.attribute_03 = ''manual'' then',
'        l_base_url := rtrim(p_plugin.attribute_04);',
'    else',
'        l_base_url := ''/i/libraries/monaco-editor/'' || p_plugin.attribute_03;',
'    end if;',
'',
'    -- add chart container',
'    htp.p(''<div id="'' || c_static_id || ''" class="apex-monaco-editor-container"></div>'');',
'    -- call script js',
'    apex_javascript.add_onload_code(''apexMonacoEditor(apex, apex.jQuery).initialize('' || ',
'    apex_javascript.add_value(c_static_id, true) ||  -- id of the chart container',
'    apex_javascript.add_value(c_refresh_id, true) || -- id where refresh is binded',
'    apex_javascript.add_value(apex_plugin.get_ajax_identifier, true) || -- id for ajax call',
'    apex_javascript.add_value(c_items2submit, true) || -- items to submit for ajax call',
'    apex_javascript.add_value(l_base_url || ''/min/vs'', true) || -- add path to editor files',
'    apex_javascript.add_value(p_region.attribute_01, true) || -- height of the editor region',
'    apex_javascript.add_value(p_region.attribute_03, true) || -- language e.g. sql',
'    apex_javascript.add_value(p_region.attribute_04, true) || -- editor theme',
'    apex_javascript.add_value(p_region.attribute_05, true) || -- list of buttons that are shown in the region e.g. save',
'    apex_javascript.add_value(apex_region.is_read_only, false) ||',
'    '');'');',
'',
'    return l_render_result;',
'end;'))
,p_api_version=>2
,p_render_function=>'F_RENDER'
,p_ajax_function=>'F_AJAX'
,p_standard_attributes=>'SOURCE_SQL:AJAX_ITEMS_TO_SUBMIT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>This plug-in is used to render the visual studio monaco code editor in APEX. You can load source code as clob and the same or another source code as diff. The plug-in is also able to store the edited code back into the database e.g. in an APEX Col'
||'lection as clob.</p>',
'<p>the following apex.region("#YOUR_STATIC_REGION_ID#") are supported:</p>',
'<ul>',
'<li>save(): Upload current content of the Editor into the Database.</li>',
'<li>setValue(pValue, pDiffValue): Set the current Content and Diff-Content of the Editor.</li>',
'<li>refresh(): Refresh the Editor Content via Ajax.</li>',
'</ul>'))
,p_version_identifier=>'25.06.26'
,p_about_url=>'https://github.com/RonnyWeiss'
,p_files_version=>413
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(79002731909017116)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Use CDN'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'Y'
,p_is_translatable=>false
,p_help_text=>'Use CDN to load required static files for the monaco editor. This settings is required when the application is using CDN!'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(78947614466865707)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Monaco Editor Base URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.51.0'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(79002731909017116)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_examples=>'https://cdnjs.cloudflare.com/ajax/libs/monaco-editor/0.51.0'
,p_help_text=>'Defines the path for the required Monaco Editor static files from the Cloudflare CDN. You can also change this value to another URL.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(79005811767045083)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'APEX Version'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'0.51.0'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(79002731909017116)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'NOT_EQUALS'
,p_depending_on_expression=>'Y'
,p_lov_type=>'STATIC'
,p_help_text=>'Select your current APEX Version or select "Manual Path" to enter your custom rleative path to the static files of the monaco editor.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(79006958245052581)
,p_plugin_attribute_id=>wwv_flow_api.id(79005811767045083)
,p_display_sequence=>10
,p_display_value=>'21.1, 21.2'
,p_return_value=>'0.22.3'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(79007323187065396)
,p_plugin_attribute_id=>wwv_flow_api.id(79005811767045083)
,p_display_sequence=>20
,p_display_value=>'22.1, 22.2, 23.1, 23.2'
,p_return_value=>'0.32.1'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(79013860605112625)
,p_plugin_attribute_id=>wwv_flow_api.id(79005811767045083)
,p_display_sequence=>30
,p_display_value=>'24.1'
,p_return_value=>'0.47.0'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(79014235805116005)
,p_plugin_attribute_id=>wwv_flow_api.id(79005811767045083)
,p_display_sequence=>40
,p_display_value=>'24.2'
,p_return_value=>'0.51.0'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(79014634671117709)
,p_plugin_attribute_id=>wwv_flow_api.id(79005811767045083)
,p_display_sequence=>50
,p_display_value=>'Manual Path'
,p_return_value=>'manual'
,p_help_text=>'Select this option to enter the path manually.'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(79015418976132020)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Monaco Editor Path'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'/i/libraries/monaco-editor/0.51.0'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(79005811767045083)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'manual'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(30127016351232264494)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Height'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'50vh'
,p_is_translatable=>false
,p_help_text=>'Set height of the editor in px, vh, %...'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(30127016719646264496)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>9999
,p_prompt=>'Execute on Save'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'declare',
'    l_collection_name varchar2(32767) := coalesce(:P1_COLLECTION_NAME, ''VS_CODE_CLOB'');',
'begin',
'    apex_collection.create_or_truncate_collection(p_collection_name => l_collection_name);',
'    apex_collection.add_member(p_collection_name => l_collection_name, p_clob001 => :CLOB);',
'exception',
'    when others then',
'        apex_debug.error(sqlerrm);',
'        apex_debug.error(dbms_utility.format_error_stack);',
'end;'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(30127053447479264523)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'save'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'declare',
'    l_collection_name varchar2(32767) := coalesce(:P1_COLLECTION_NAME, ''VS_CODE_CLOB'');',
'begin',
'    apex_collection.create_or_truncate_collection(p_collection_name => l_collection_name);',
'    apex_collection.add_member(p_collection_name => l_collection_name, p_clob001 => :CLOB);',
'exception',
'    when others then',
'        apex_debug.error(sqlerrm);',
'        apex_debug.error(dbms_utility.format_error_stack);',
'end;',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(30127017095926264496)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Language'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'sql'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Set the language for the editor. This setting can be overwritten by the sql query source. Just set language in JSON like it''s in this select list attribute.'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127037541830264511)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>10
,p_display_value=>'abap'
,p_return_value=>'abap'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127031519945264507)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>20
,p_display_value=>'azcli'
,p_return_value=>'azcli'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127020567644264499)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>30
,p_display_value=>'bat'
,p_return_value=>'bat'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127032017323264507)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>40
,p_display_value=>'c'
,p_return_value=>'c'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127048001368264519)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>50
,p_display_value=>'cameligo'
,p_return_value=>'cameligo'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127020974218264499)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>60
,p_display_value=>'clojure'
,p_return_value=>'clojure'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127021547592264500)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>70
,p_display_value=>'coffeescript'
,p_return_value=>'coffeescript'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127042068387264514)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>80
,p_display_value=>'cpp'
,p_return_value=>'cpp'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127021999182264500)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>90
,p_display_value=>'csharp'
,p_return_value=>'csharp'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127037983340264511)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>100
,p_display_value=>'csp'
,p_return_value=>'csp'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127038519279264512)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>110
,p_display_value=>'css'
,p_return_value=>'css'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127038971992264512)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>120
,p_display_value=>'dart'
,p_return_value=>'dart'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127032481301264507)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>130
,p_display_value=>'dockerfile'
,p_return_value=>'dockerfile'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127048493865264519)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>140
,p_display_value=>'fsharp'
,p_return_value=>'fsharp'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127049055573264519)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>150
,p_display_value=>'go'
,p_return_value=>'go'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127022497988264500)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>160
,p_display_value=>'graphql'
,p_return_value=>'graphql'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127042544804264514)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>170
,p_display_value=>'handlebars'
,p_return_value=>'handlebars'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127039531868264512)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>180
,p_display_value=>'hcl'
,p_return_value=>'hcl'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127035041272264509)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>190
,p_display_value=>'html'
,p_return_value=>'html'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127043005683264515)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>200
,p_display_value=>'ini'
,p_return_value=>'ini'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127035497906264509)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>210
,p_display_value=>'java'
,p_return_value=>'java'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127043494631264515)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>220
,p_display_value=>'javascript'
,p_return_value=>'javascript'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127033013691264508)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>230
,p_display_value=>'json'
,p_return_value=>'json'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127036004014264510)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>240
,p_display_value=>'julia'
,p_return_value=>'julia'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127036502753264510)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>250
,p_display_value=>'kotlin'
,p_return_value=>'kotlin'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127036986496264510)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>260
,p_display_value=>'less'
,p_return_value=>'less'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127044063230264516)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>270
,p_display_value=>'lexon'
,p_return_value=>'lexon'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127044513889264516)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>280
,p_display_value=>'lua'
,p_return_value=>'lua'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127023054805264501)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>290
,p_display_value=>'markdown'
,p_return_value=>'markdown'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127023492025264501)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>300
,p_display_value=>'mips'
,p_return_value=>'mips'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127040970524264513)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>310
,p_display_value=>'msdax'
,p_return_value=>'msdax'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127033528754264508)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>320
,p_display_value=>'mysql'
,p_return_value=>'mysql'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127017491926264496)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>330
,p_display_value=>'objective-c'
,p_return_value=>'objective-c'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127041469026264514)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>340
,p_display_value=>'pascal'
,p_return_value=>'pascal'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127017992260264497)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>350
,p_display_value=>'pascaligo'
,p_return_value=>'pascaligo'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127024034305264501)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>360
,p_display_value=>'perl'
,p_return_value=>'perl'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127024473340264502)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>370
,p_display_value=>'pgsql'
,p_return_value=>'pgsql'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127028501852264505)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>380
,p_display_value=>'php'
,p_return_value=>'php'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127018509889264497)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>390
,p_display_value=>'plaintext'
,p_return_value=>'plaintext'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127026009531264503)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>400
,p_display_value=>'postiats'
,p_return_value=>'postiats'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127025034389264502)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>410
,p_display_value=>'powerquery'
,p_return_value=>'powerquery'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127026566775264503)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>420
,p_display_value=>'powershell'
,p_return_value=>'powershell'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127045049582264517)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>430
,p_display_value=>'pug'
,p_return_value=>'pug'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127045529092264517)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>440
,p_display_value=>'python'
,p_return_value=>'python'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127026982732264504)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>450
,p_display_value=>'r'
,p_return_value=>'r'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127029000262264505)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>460
,p_display_value=>'razor'
,p_return_value=>'razor'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127029540504264505)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>470
,p_display_value=>'redis'
,p_return_value=>'redis'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127027548353264504)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>480
,p_display_value=>'redshift'
,p_return_value=>'redshift'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127030039896264506)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>490
,p_display_value=>'restructuredtext'
,p_return_value=>'restructuredtext'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127025469968264502)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>500
,p_display_value=>'ruby'
,p_return_value=>'ruby'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127034052948264508)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>510
,p_display_value=>'rust'
,p_return_value=>'rust'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127028037976264504)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>520
,p_display_value=>'sb'
,p_return_value=>'sb'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127030527524264506)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>530
,p_display_value=>'scala'
,p_return_value=>'scala'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127045990666264517)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>540
,p_display_value=>'scheme'
,p_return_value=>'scheme'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127034551259264509)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>550
,p_display_value=>'scss'
,p_return_value=>'scss'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127049482461264520)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>560
,p_display_value=>'shell'
,p_return_value=>'shell'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127019064178264498)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>570
,p_display_value=>'sol'
,p_return_value=>'sol'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127050053923264520)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>580
,p_display_value=>'sql'
,p_return_value=>'sql'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127046479862264518)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>590
,p_display_value=>'st'
,p_return_value=>'st'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127050473058264521)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>600
,p_display_value=>'swift'
,p_return_value=>'swift'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127051013239264521)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>610
,p_display_value=>'systemverilog'
,p_return_value=>'systemverilog'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127019522948264498)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>620
,p_display_value=>'tcl'
,p_return_value=>'tcl'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127031057220264506)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>630
,p_display_value=>'twig'
,p_return_value=>'twig'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127047043062264518)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>640
,p_display_value=>'typescript'
,p_return_value=>'typescript'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127047559998264518)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>650
,p_display_value=>'vb'
,p_return_value=>'vb'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127040538409264513)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>660
,p_display_value=>'verilog'
,p_return_value=>'verilog'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127039992392264513)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>670
,p_display_value=>'xml'
,p_return_value=>'xml'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127020007747264498)
,p_plugin_attribute_id=>wwv_flow_api.id(30127017095926264496)
,p_display_sequence=>680
,p_display_value=>'yaml'
,p_return_value=>'yaml'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(30127051494687264521)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Theme'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'vs-dark'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Set Theme of the editor'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127052461194264522)
,p_plugin_attribute_id=>wwv_flow_api.id(30127051494687264521)
,p_display_sequence=>10
,p_display_value=>'Visual Studio Dark'
,p_return_value=>'vs-dark'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127052872038264522)
,p_plugin_attribute_id=>wwv_flow_api.id(30127051494687264521)
,p_display_sequence=>20
,p_display_value=>'Visual Studio'
,p_return_value=>'vs'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127051938399264522)
,p_plugin_attribute_id=>wwv_flow_api.id(30127051494687264521)
,p_display_sequence=>30
,p_display_value=>'High Contrast Black'
,p_return_value=>'hc-black'
,p_is_quick_pick=>true
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(30127053447479264523)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Buttons'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'undo:redo:search:diff:save'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Set the buttons that should be shown above the editor.'
);
end;
/
begin
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127055327210264524)
,p_plugin_attribute_id=>wwv_flow_api.id(30127053447479264523)
,p_display_sequence=>10
,p_display_value=>'Undo'
,p_return_value=>'undo'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127054361636264523)
,p_plugin_attribute_id=>wwv_flow_api.id(30127053447479264523)
,p_display_sequence=>20
,p_display_value=>'Redo'
,p_return_value=>'redo'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127054812891264524)
,p_plugin_attribute_id=>wwv_flow_api.id(30127053447479264523)
,p_display_sequence=>30
,p_display_value=>'Search'
,p_return_value=>'search'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127055804369264525)
,p_plugin_attribute_id=>wwv_flow_api.id(30127053447479264523)
,p_display_sequence=>40
,p_display_value=>'Switch between Single Editor and Diff-Editor'
,p_return_value=>'diff'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(30127053796858264523)
,p_plugin_attribute_id=>wwv_flow_api.id(30127053447479264523)
,p_display_sequence=>50
,p_display_value=>'Save'
,p_return_value=>'save'
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(30127057056540264530)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_name=>'SOURCE_SQL'
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'select',
'    -- value of the editor that can be edited and saved',
'    ''DECLARE',
'    TEXT VARCHAR2(25);',
'BEGIN',
'    TEXT := ''''HELLO World'''';',
'    DBMS_OUTPUT.PUT_LINE(TEXT);',
'END;'' as value_edit,',
'    -- value to make diff with first value',
'    ''DECLARE',
'    TEXT VARCHAR2(25);',
'BEGIN',
'    TEXT := ''''HELLO World'''';',
'    DBMS_OUTPUT.PUT_LINE(TEXT);',
'END;'' as value_diff,',
'    -- language that should be used e.g. sql, javascript, json..., all avail. languages you find in attributes',
'    ''sql'' as language',
'from',
'    dual'))
,p_sql_min_column_count=>1
,p_sql_max_column_count=>3
,p_depending_on_has_to_exist=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'select',
'    -- value of the editor that can be edited and saved',
'    ''DECLARE',
'    TEXT VARCHAR2(25);',
'BEGIN',
'    TEXT := ''''HELLO World'''';',
'    DBMS_OUTPUT.PUT_LINE(TEXT);',
'END;'' as value_edit,',
'    -- value to make diff with first value',
'    ''DECLARE',
'    TEXT VARCHAR2(25);',
'BEGIN',
'    TEXT := ''''HELLO World'''';',
'    DBMS_OUTPUT.PUT_LINE(TEXT);',
'END;'' as value_diff,',
'    -- language that should be used e.g. sql, javascript, json..., all avail. languages you find in attributes',
'    ''sql'' as language',
'from',
'    dual',
'</pre>'))
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(30127057468376264532)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_name=>'rendered'
,p_display_name=>'Rendered'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(30127057772100264533)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_name=>'upload-error'
,p_display_name=>'Upload of Text has caused an error'
);
wwv_flow_api.create_plugin_event(
 p_id=>wwv_flow_api.id(30127058206484264533)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_name=>'upload-finished'
,p_display_name=>'Upload of Text finished'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '4D4954204C6963656E73650A0A436F7079726967687420286329203230323520526F6E6E792057656973732C20546F626961732041726E686F6C640A0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F662063';
wwv_flow_api.g_varchar2_table(2) := '68617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F70790A6F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468652022536F6674';
wwv_flow_api.g_varchar2_table(3) := '7761726522292C20746F206465616C0A696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E20746865207269676874730A746F207573652C';
wwv_flow_api.g_varchar2_table(4) := '20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C0A636F70696573206F662074686520536F6674776172652C20616E6420746F207065';
wwv_flow_api.g_varchar2_table(5) := '726D697420706572736F6E7320746F2077686F6D2074686520536F6674776172652069730A6675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0A0A5468652061';
wwv_flow_api.g_varchar2_table(6) := '626F766520636F70797269676874206E6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C0A636F70696573206F72207375627374616E7469616C20706F7274';
wwv_flow_api.g_varchar2_table(7) := '696F6E73206F662074686520536F6674776172652E0A0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F520A494D';
wwv_flow_api.g_varchar2_table(8) := '504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C0A4649544E45535320464F52204120504152544943554C41522050555250';
wwv_flow_api.g_varchar2_table(9) := '4F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556454E54205348414C4C205448450A415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C';
wwv_flow_api.g_varchar2_table(10) := '2044414D41474553204F52204F544845520A4C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C0A4F555420';
wwv_flow_api.g_varchar2_table(11) := '4F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E205448450A534F4654574152452E0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(78944996557350039)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_file_name=>'LICENSE'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '4C617374207570646174653A20323032312D30312D31320D0A0D0A23232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323';
wwv_flow_api.g_varchar2_table(2) := '2323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323230D0A0D0A4C6963656E7365204D6F6E61636F20456469746F72202D2068747470733A';
wwv_flow_api.g_varchar2_table(3) := '2F2F6769746875622E636F6D2F4D6963726F736F66742F6D6F6E61636F2D656469746F720D0A0D0A546865204D4954204C6963656E736520284D4954290D0A0D0A436F70797269676874202863292032303136202D2070726573656E74204D6963726F73';
wwv_flow_api.g_varchar2_table(4) := '6F667420436F72706F726174696F6E0D0A0D0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E7920706572736F6E206F627461696E696E67206120636F7079206F662074';
wwv_flow_api.g_varchar2_table(5) := '68697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C20696E2074686520536F66747761726520776974686F7574207265';
wwv_flow_api.g_varchar2_table(6) := '737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E207468652072696768747320746F207573652C20636F70792C206D6F646966792C206D657267652C207075626C6973682C20646973747269627574652C';
wwv_flow_api.g_varchar2_table(7) := '207375626C6963656E73652C20616E642F6F722073656C6C20636F70696573206F662074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F2077686F6D2074686520536F667477617265206973206675726E69';
wwv_flow_api.g_varchar2_table(8) := '7368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0D0A0D0A5468652061626F766520636F70797269676874206E6F7469636520616E642074686973207065726D697373696F';
wwv_flow_api.g_varchar2_table(9) := '6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C20636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674776172652E0D0A0D0A54484520534F465457415245204953';
wwv_flow_api.g_varchar2_table(10) := '2050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F5220494D504C4945442C20494E434C5544494E4720425554204E4F54204C494D4954454420544F205448';
wwv_flow_api.g_varchar2_table(11) := '452057415252414E54494553204F46204D45524348414E544142494C4954592C204649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E4652494E47454D454E542E20494E204E4F204556454E542053';
wwv_flow_api.g_varchar2_table(12) := '48414C4C2054484520415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F54484552204C494142494C4954592C20574845544845522049';
wwv_flow_api.g_varchar2_table(13) := '4E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C204F5554204F46204F5220494E20434F4E4E454354494F4E20574954482054484520534F46545741524520';
wwv_flow_api.g_varchar2_table(14) := '4F522054484520555345204F52204F54484552204445414C494E475320494E2054484520534F4654574152452E0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(78945272486350040)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_file_name=>'LICENSE4LIBS'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '636F6E737420617065784D6F6E61636F456469746F72203D2066756E6374696F6E2028617065782C202429207B0D0A202020202275736520737472696374223B0D0A20202020636F6E7374207574696C203D207B0D0A2020202020202020226665617475';
wwv_flow_api.g_varchar2_table(2) := '726544657461696C73223A207B0D0A2020202020202020202020206E616D653A2022415045582D56532D4D6F6E61636F2D456469746F72222C0D0A20202020202020202020202073637269707456657273696F6E3A202232352E30362E3236222C0D0A20';
wwv_flow_api.g_varchar2_table(3) := '20202020202020202020207574696C56657273696F6E3A202232322E31312E3238222C0D0A20202020202020202020202075726C3A202268747470733A2F2F6769746875622E636F6D2F526F6E6E795765697373222C0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(4) := '6C6963656E73653A20224D49542D4C6963656E7365220D0A20202020202020207D2C0D0A20202020202020206973446566696E6564416E644E6F744E756C6C3A2066756E6374696F6E202870496E70757429207B0D0A2020202020202020202020206966';
wwv_flow_api.g_varchar2_table(5) := '2028747970656F662070496E70757420213D3D2022756E646566696E6564222026262070496E70757420213D3D206E756C6C2026262070496E70757420213D20222229207B0D0A2020202020202020202020202020202072657475726E20747275653B0D';
wwv_flow_api.g_varchar2_table(6) := '0A2020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202072657475726E2066616C73653B0D0A2020202020202020202020207D0D0A20202020202020207D2C0D0A20202020202020206C6F616465723A207B0D0A';
wwv_flow_api.g_varchar2_table(7) := '20202020202020202020202073746172743A2066756E6374696F6E202869642C207365744D696E48656967687429207B0D0A20202020202020202020202020202020696620287365744D696E48656967687429207B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(8) := '2020202020202024286964292E63737328226D696E2D686569676874222C2022313030707822293B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020202020617065782E7574696C2E73686F775370696E6E65722824';
wwv_flow_api.g_varchar2_table(9) := '28696429293B0D0A2020202020202020202020207D2C0D0A20202020202020202020202073746F703A2066756E6374696F6E202869642C2072656D6F76654D696E48656967687429207B0D0A202020202020202020202020202020206966202872656D6F';
wwv_flow_api.g_varchar2_table(10) := '76654D696E48656967687429207B0D0A202020202020202020202020202020202020202024286964292E63737328226D696E2D686569676874222C202222293B0D0A202020202020202020202020202020207D0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(11) := '2024286964202B2022203E202E752D50726F63657373696E6722292E72656D6F766528293B0D0A2020202020202020202020202020202024286964202B2022203E202E63742D6C6F6164657222292E72656D6F766528293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(12) := '20207D0D0A20202020202020207D0D0A202020207D3B0D0A202020206C657420656469746F722C0D0A2020202020202020697344696666456469746F72203D2066616C73653B0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(13) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020202A2A0D0A20202020202A2A205573656420746F2075706C6F616420636C6F620D0A20202020202A2A0D0A20';
wwv_flow_api.g_varchar2_table(14) := '202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E2075706C6F616446696C';
wwv_flow_api.g_varchar2_table(15) := '65732870436F6E6669672C207053747229207B0D0A20202020202020207574696C2E6C6F616465722E73746172742870436F6E6669672E726567696F6E53656C293B0D0A0D0A2020202020202020636F6E737420737472417272203D20617065782E7365';
wwv_flow_api.g_varchar2_table(16) := '727665722E6368756E6B2870537472292C0D0A2020202020202020202020206974656D73325375626D6974203D2070436F6E6669672E6974656D73325375626D69743B0D0A0D0A2020202020202020617065782E64656275672E696E666F287B0D0A2020';
wwv_flow_api.g_varchar2_table(17) := '2020202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E616D65202B2022202D2022202B202275706C6F616446696C6573222C0D0A202020202020202020202020226D7367223A202255706C6F6164207374617274';
wwv_flow_api.g_varchar2_table(18) := '656421222C0D0A20202020202020202020202022737472417272223A207374724172722C0D0A202020202020202020202020226665617475726544657461696C73223A207574696C2E6665617475726544657461696C730D0A20202020202020207D293B';
wwv_flow_api.g_varchar2_table(19) := '0D0A0D0A2020202020202020617065782E7365727665722E706C7567696E2870436F6E6669672E616A617849442C207B0D0A2020202020202020202020207830313A2022504F5354222C0D0A2020202020202020202020206630313A207374724172722C';
wwv_flow_api.g_varchar2_table(20) := '0D0A202020202020202020202020706167654974656D733A206974656D73325375626D69740D0A20202020202020207D2C207B0D0A202020202020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(21) := '20202020202020202020242870436F6E6669672E726567696F6E49445265667265736853656C292E74726967676572282275706C6F61642D66696E697368656422293B0D0A20202020202020202020202020202020617065782E64656275672E696E666F';
wwv_flow_api.g_varchar2_table(22) := '287B0D0A202020202020202020202020202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E616D65202B2022202D2022202B202275706C6F616446696C6573222C0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(23) := '2020226D7367223A202255706C6F61642066696E697368656421222C0D0A2020202020202020202020202020202020202020227044617461223A2070446174612C0D0A202020202020202020202020202020202020202022666561747572654465746169';
wwv_flow_api.g_varchar2_table(24) := '6C73223A207574696C2E6665617475726544657461696C730D0A202020202020202020202020202020207D293B0D0A202020202020202020202020202020207574696C2E6C6F616465722E73746F702870436F6E6669672E726567696F6E53656C293B0D';
wwv_flow_api.g_varchar2_table(25) := '0A2020202020202020202020207D2C0D0A2020202020202020202020206572726F723A2066756E6374696F6E20286A715848522C20746578745374617475732C206572726F725468726F776E29207B0D0A20202020202020202020202020202020242870';
wwv_flow_api.g_varchar2_table(26) := '436F6E6669672E726567696F6E49445265667265736853656C292E74726967676572282275706C6F61642D6572726F7222293B0D0A20202020202020202020202020202020617065782E64656275672E6572726F72287B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(27) := '20202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E616D65202B2022202D2022202B202275706C6F616446696C6573222C0D0A2020202020202020202020202020202020202020226D7367223A202255706C6F61';
wwv_flow_api.g_varchar2_table(28) := '64206572726F7221222C0D0A2020202020202020202020202020202020202020226A71584852223A206A715848522C0D0A20202020202020202020202020202020202020202274657874537461747573223A20746578745374617475732C0D0A20202020';
wwv_flow_api.g_varchar2_table(29) := '20202020202020202020202020202020226572726F725468726F776E223A206572726F725468726F776E2C0D0A2020202020202020202020202020202020202020226665617475726544657461696C73223A207574696C2E666561747572654465746169';
wwv_flow_api.g_varchar2_table(30) := '6C730D0A202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020207574696C2E6C6F616465722E73746F702870436F6E6669672E726567696F6E53656C293B0D0A2020202020202020202020207D0D0A20202020';
wwv_flow_api.g_varchar2_table(31) := '202020207D293B0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020';
wwv_flow_api.g_varchar2_table(32) := '202A2A0D0A20202020202A2A205573656420746F20696E697420616E20656469746F720D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(33) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E20696E6974456469746F722870436F6E6669672C20704F72675374722C20704469666653747229207B0D0A2020202020202020636F6E737420656C203D2064';
wwv_flow_api.g_varchar2_table(34) := '6F63756D656E742E676574456C656D656E74427949642870436F6E6669672E726567696F6E4944293B0D0A0D0A202020202020202069662028697344696666456469746F7229207B0D0A202020202020202020202020636F6E7374206F726967696E616C';
wwv_flow_api.g_varchar2_table(35) := '4D6F64656C203D206D6F6E61636F2E656469746F722E6372656174654D6F64656C28704F72675374722C2070436F6E6669672E6C616E6775616765292C0D0A202020202020202020202020202020206D6F6469666965644D6F64656C203D206D6F6E6163';
wwv_flow_api.g_varchar2_table(36) := '6F2E656469746F722E6372656174654D6F64656C2870446966665374722C2070436F6E6669672E6C616E6775616765293B0D0A0D0A202020202020202020202020656469746F72203D206D6F6E61636F2E656469746F722E637265617465446966664564';
wwv_flow_api.g_varchar2_table(37) := '69746F7228656C2C207B0D0A202020202020202020202020202020206F726967696E616C4564697461626C653A202170436F6E6669672E726561644F6E6C792C0D0A20202020202020202020202020202020726561644F6E6C793A20747275652C0D0A20';
wwv_flow_api.g_varchar2_table(38) := '2020202020202020202020202020206C616E67756167653A2070436F6E6669672E6C616E67756167652C0D0A202020202020202020202020202020207468656D653A2070436F6E6669672E7468656D652C0D0A2020202020202020202020202020202061';
wwv_flow_api.g_varchar2_table(39) := '75746F6D617469634C61796F75743A20747275650D0A2020202020202020202020207D293B0D0A0D0A202020202020202020202020656469746F722E7365744D6F64656C287B0D0A202020202020202020202020202020206F726967696E616C3A206F72';
wwv_flow_api.g_varchar2_table(40) := '6967696E616C4D6F64656C2C0D0A202020202020202020202020202020206D6F6469666965643A206D6F6469666965644D6F64656C0D0A2020202020202020202020207D293B0D0A20202020202020207D20656C7365207B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(41) := '2020656469746F72203D206D6F6E61636F2E656469746F722E63726561746528656C2C207B0D0A2020202020202020202020202020202076616C75653A20704F72675374722C0D0A202020202020202020202020202020206C616E67756167653A207043';
wwv_flow_api.g_varchar2_table(42) := '6F6E6669672E6C616E67756167652C0D0A202020202020202020202020202020207468656D653A2070436F6E6669672E7468656D652C0D0A202020202020202020202020202020206175746F6D617469634C61796F75743A20747275652C0D0A20202020';
wwv_flow_api.g_varchar2_table(43) := '202020202020202020202020726561644F6E6C793A2070436F6E6669672E726561644F6E6C790D0A2020202020202020202020207D293B0D0A20202020202020207D0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(44) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020202A2A0D0A20202020202A2A205573656420746F20637265617465206120627574746F6E0D0A202020';
wwv_flow_api.g_varchar2_table(45) := '20202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E206372';
wwv_flow_api.g_varchar2_table(46) := '65617465427574746F6E287049636F6E29207B0D0A20202020202020206C65742069636F6E436F6E7461696E6572203D202428223C6469763E3C2F6469763E22293B0D0A202020202020202069636F6E436F6E7461696E65722E616464436C6173732822';
wwv_flow_api.g_varchar2_table(47) := '617065782D76732D6D6F6E61636F2D656469746F722D746F6F6C6261722D636F6E7461696E65722D62746E22293B0D0A202020202020202069636F6E436F6E7461696E65722E616464436C6173732822612D427574746F6E22293B0D0A0D0A2020202020';
wwv_flow_api.g_varchar2_table(48) := '2020206C65742069636F6E203D202428223C7370616E3E3C2F7370616E3E22290D0A202020202020202069636F6E2E616464436C6173732822666122293B0D0A202020202020202069636F6E2E616464436C617373287049636F6E293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(49) := '20202069636F6E2E616464436C6173732822617065782D76732D6D6F6E61636F2D656469746F722D746F6F6C6261722D636F6E7461696E65722D62746E2D69636F6E22293B0D0A0D0A202020202020202069636F6E436F6E7461696E65722E617070656E';
wwv_flow_api.g_varchar2_table(50) := '642869636F6E293B0D0A202020202020202072657475726E2069636F6E436F6E7461696E65723B0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(51) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020202A2A0D0A20202020202A2A2066756E6374696F6E20746F20736176652063757272656E742064617461206F662074686520656469746F7220696E746F20746865206461';
wwv_flow_api.g_varchar2_table(52) := '7461626173650D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A20202020';
wwv_flow_api.g_varchar2_table(53) := '66756E6374696F6E2073617665436F6E74656E742870436F6E66696729207B0D0A20202020202020206C6574207374723B0D0A202020202020202069662028697344696666456469746F7229207B0D0A202020202020202020202020737472203D206564';
wwv_flow_api.g_varchar2_table(54) := '69746F722E6765744D6F64656C28292E6F726967696E616C2E67657456616C756528293B0D0A20202020202020207D20656C7365207B0D0A202020202020202020202020737472203D20656469746F722E67657456616C756528293B0D0A202020202020';
wwv_flow_api.g_varchar2_table(55) := '20207D0D0A202020202020202075706C6F616446696C65732870436F6E6669672C20737472293B0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(56) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020202A2A0D0A20202020202A2A205573656420746F2072656E64657220546F6F6C6261720D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(57) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E20616464546F6F6C6261722870436F6E6669672C2070446966665374722920';
wwv_flow_api.g_varchar2_table(58) := '7B0D0A20202020202020206C657420736561726368203D2066616C73653B0D0A0D0A20202020202020206966202870436F6E6669672E627574746F6E735374722026262070436F6E6669672E627574746F6E735374722E6C656E677468203E203029207B';
wwv_flow_api.g_varchar2_table(59) := '0D0A0D0A2020202020202020202020206C657420636F6E7461696E6572203D202428223C6469763E3C2F6469763E22293B0D0A202020202020202020202020636F6E7461696E65722E616464436C6173732822617065782D76732D6D6F6E61636F2D6564';
wwv_flow_api.g_varchar2_table(60) := '69746F722D746F6F6C6261722D636F6E7461696E657222293B0D0A202020202020202020202020636F6E7461696E65722E6373732822626F726465722D626F74746F6D222C202231707820736F6C6964207267626128302C302C302C302E303735292229';
wwv_flow_api.g_varchar2_table(61) := '3B0D0A0D0A2020202020202020202020206966202870436F6E6669672E627574746F6E732E696E6465784F662822756E646F2229203E202D3129207B0D0A2020202020202020202020202020202076617220756E646F42746E203D206372656174654275';
wwv_flow_api.g_varchar2_table(62) := '74746F6E282266612D756E646F22293B0D0A20202020202020202020202020202020756E646F42746E2E6F6E2822636C69636B222C2066756E6374696F6E202829207B0D0A20202020202020202020202020202020202020206966202869734469666645';
wwv_flow_api.g_varchar2_table(63) := '6469746F7229207B0D0A202020202020202020202020202020202020202020202020656469746F722E6765744F726967696E616C456469746F7228292E6765744D6F64656C28292E756E646F28293B0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(64) := '207D20656C7365207B0D0A202020202020202020202020202020202020202020202020656469746F722E6765744D6F64656C28292E756E646F28293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(65) := '207D293B0D0A20202020202020202020202020202020636F6E7461696E65722E617070656E6428756E646F42746E293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020206966202870436F6E6669672E627574746F6E732E69';
wwv_flow_api.g_varchar2_table(66) := '6E6465784F6628227265646F2229203E202D3129207B0D0A202020202020202020202020202020206C65742072657065617442746E203D20637265617465427574746F6E282266612D72657065617422293B0D0A0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(67) := '202072657065617442746E2E6F6E2822636C69636B222C2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202069662028697344696666456469746F7229207B0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(68) := '20202020656469746F722E6765744F726967696E616C456469746F7228292E6765744D6F64656C28292E7265646F28293B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(69) := '2020202020656469746F722E6765744D6F64656C28292E7265646F28293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A20202020202020202020202020202020636F6E7461696E65';
wwv_flow_api.g_varchar2_table(70) := '722E617070656E642872657065617442746E293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020206966202870436F6E6669672E627574746F6E732E696E6465784F6628227365617263682229203E202D3129207B0D0A2020';
wwv_flow_api.g_varchar2_table(71) := '20202020202020202020202020206C65742073656172636842746E203D20637265617465427574746F6E282266612D73656172636822293B0D0A0D0A2020202020202020202020202020202073656172636842746E2E6F6E2822636C69636B222C206675';
wwv_flow_api.g_varchar2_table(72) := '6E6374696F6E202829207B0D0A2020202020202020202020202020202020202020736561726368203D20217365617263683B0D0A20202020202020202020202020202020202020206966202873656172636829207B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(73) := '202020202020202020202069662028697344696666456469746F7229207B0D0A20202020202020202020202020202020202020202020202020202020656469746F722E6765744F726967696E616C456469746F7228292E676574416374696F6E28276163';
wwv_flow_api.g_varchar2_table(74) := '74696F6E732E66696E6427292E72756E28293B0D0A20202020202020202020202020202020202020202020202020202020656469746F722E6765744D6F646966696564456469746F7228292E676574416374696F6E2827616374696F6E732E66696E6427';
wwv_flow_api.g_varchar2_table(75) := '292E72756E28293B0D0A2020202020202020202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202020202020656469746F722E676574416374696F6E2827616374696F6E732E6669';
wwv_flow_api.g_varchar2_table(76) := '6E6427292E72756E28293B0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020696620286973';
wwv_flow_api.g_varchar2_table(77) := '44696666456469746F7229207B0D0A20202020202020202020202020202020202020202020202020202020656469746F722E6765744F726967696E616C456469746F7228292E7472696767657228276B6579626F617264272C2027636C6F736546696E64';
wwv_flow_api.g_varchar2_table(78) := '57696467657427293B0D0A20202020202020202020202020202020202020202020202020202020656469746F722E6765744D6F646966696564456469746F7228292E7472696767657228276B6579626F617264272C2027636C6F736546696E6457696467';
wwv_flow_api.g_varchar2_table(79) := '657427293B0D0A2020202020202020202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202020202020656469746F722E7472696767657228276B6579626F617264272C2027636C6F';
wwv_flow_api.g_varchar2_table(80) := '736546696E6457696467657427293B0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(81) := '20202020636F6E7461696E65722E617070656E642873656172636842746E293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020206966202870436F6E6669672E627574746F6E732E696E6465784F662822646966662229203E';
wwv_flow_api.g_varchar2_table(82) := '202D3129207B0D0A202020202020202020202020202020206C6574206469666642746E203D20637265617465427574746F6E282266612D6172726F77732D6822293B0D0A0D0A202020202020202020202020202020206469666642746E2E6F6E2822636C';
wwv_flow_api.g_varchar2_table(83) := '69636B222C2066756E6374696F6E202829207B0D0A20202020202020202020202020202020202020206C6574207374723B0D0A0D0A2020202020202020202020202020202020202020736561726368203D2066616C73653B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(84) := '20202020202020202020697344696666456469746F72203D2021697344696666456469746F723B0D0A20202020202020202020202020202020202020206966202821697344696666456469746F7229207B0D0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(85) := '20202020202020737472203D20656469746F722E6765744D6F64656C28292E6F726967696E616C2E67657456616C756528293B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(86) := '20202020202020737472203D20656469746F722E67657456616C756528293B0D0A20202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020656469746F722E646973706F736528293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(87) := '202020202020202020202020202020696E6974456469746F722870436F6E6669672C207374722C207044696666537472293B0D0A202020202020202020202020202020207D293B0D0A20202020202020202020202020202020636F6E7461696E65722E61';
wwv_flow_api.g_varchar2_table(88) := '7070656E64286469666642746E293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020206966202870436F6E6669672E627574746F6E732E696E6465784F662822736176652229203E202D3129207B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(89) := '202020202020206C6574207361766542746E203D20637265617465427574746F6E282266612D7361766522293B0D0A0D0A202020202020202020202020202020207361766542746E2E6F6E2822636C69636B222C2066756E6374696F6E202829207B0D0A';
wwv_flow_api.g_varchar2_table(90) := '20202020202020202020202020202020202020206C6574207374723B0D0A202020202020202020202020202020202020202069662028697344696666456469746F7229207B0D0A202020202020202020202020202020202020202020202020737472203D';
wwv_flow_api.g_varchar2_table(91) := '20656469746F722E6765744D6F64656C28292E6F726967696E616C2E67657456616C756528293B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020737472203D';
wwv_flow_api.g_varchar2_table(92) := '20656469746F722E67657456616C756528293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202075706C6F616446696C65732870436F6E6669672C20737472293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(93) := '20202020202020207D293B0D0A20202020202020202020202020202020636F6E7461696E65722E617070656E64287361766542746E293B0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020242870436F6E6669672E72656769';
wwv_flow_api.g_varchar2_table(94) := '6F6E53656C292E70726570656E6428636F6E7461696E6572293B0D0A20202020202020207D0D0A0D0A20202020202020202F2F207472696767657220656469746F722066726F6D206F75747369646520746F20736176652074686520746578740D0A2020';
wwv_flow_api.g_varchar2_table(95) := '202020202020242870436F6E6669672E726567696F6E49445265667265736853656C292E6F6E282273617665222C2066756E6374696F6E202829207B0D0A20202020202020202020202073617665436F6E74656E742870436F6E666967293B0D0A202020';
wwv_flow_api.g_varchar2_table(96) := '20202020207D293B0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A202020';
wwv_flow_api.g_varchar2_table(97) := '20202A2A0D0A20202020202A2A2066756E6374696F6E20746F20736574207468652076616C7565206F6620746865206D6F6E61636F456469746F720D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(98) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E2073657456616C7565287056616C75652C20704469666656616C756529207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(99) := '202069662028697344696666456469746F7229207B0D0A202020202020202020202020656469746F722E6765744F726967696E616C456469746F7228292E6765744D6F64656C28292E73657456616C7565287056616C7565293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(100) := '20202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C28704469666656616C75652929207B0D0A20202020202020202020202020202020656469746F722E6765744D6F646966696564456469746F7228292E6765744D6F64656C';
wwv_flow_api.g_varchar2_table(101) := '28292E73657456616C756528704469666656616C7565293B0D0A2020202020202020202020207D0D0A20202020202020207D20656C7365207B0D0A202020202020202020202020656469746F722E6765744D6F64656C28292E73657456616C7565287056';
wwv_flow_api.g_varchar2_table(102) := '616C7565293B0D0A20202020202020207D0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(103) := '2A2A2A2A0D0A20202020202A2A0D0A20202020202A2A2066756E6374696F6E20746F20696E697420746865206D6F6E61636F456469746F720D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(104) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E206C6F6164456469746F722870446174612C2070436F6E6669672C207049735265667265736829207B0D';
wwv_flow_api.g_varchar2_table(105) := '0A20202020202020206C6574207374722C0D0A202020202020202020202020737472446966663B0D0A0D0A2020202020202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C2870446174612929207B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(106) := '202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C2870446174612E726F77732929207B0D0A20202020202020202020202020202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C2870446174612E72';
wwv_flow_api.g_varchar2_table(107) := '6F77735B305D2929207B0D0A2020202020202020202020202020202020202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C2870446174612E726F77735B305D2E56414C55455F454449542929207B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(108) := '202020202020202020202020202020737472203D2070446174612E726F77735B305D2E56414C55455F454449543B0D0A20202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020696620287574696C2E';
wwv_flow_api.g_varchar2_table(109) := '6973446566696E6564416E644E6F744E756C6C2870446174612E726F77735B305D2E56414C55455F444946462929207B0D0A20202020202020202020202020202020202020202020202073747244696666203D2070446174612E726F77735B305D2E5641';
wwv_flow_api.g_varchar2_table(110) := '4C55455F444946463B0D0A202020202020202020202020202020202020202020202020697344696666456469746F72203D20747275653B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(111) := '202020202020202020202073747244696666203D207374723B0D0A20202020202020202020202020202020202020207D0D0A2020202020202020202020202020202020202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C2870';
wwv_flow_api.g_varchar2_table(112) := '446174612E726F77735B305D2E4C414E47554147452929207B0D0A20202020202020202020202020202020202020202020202070436F6E6669672E6C616E6775616765203D2070446174612E726F77735B305D2E4C414E47554147453B0D0A2020202020';
wwv_flow_api.g_varchar2_table(113) := '2020202020202020202020202020207D0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A20202020202020207D0D0A0D0A2020202020202020696620287049735265667265736829207B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(114) := '2020202073657456616C7565287374722C2073747244696666293B0D0A2020202020202020202020207574696C2E6C6F616465722E73746F702870436F6E6669672E726567696F6E53656C293B0D0A20202020202020207D20656C7365207B0D0A202020';
wwv_flow_api.g_varchar2_table(115) := '202020202020202020726571756972652E636F6E666967287B0D0A2020202020202020202020202020202070617468733A207B0D0A2020202020202020202020202020202020202020277673273A2070436F6E6669672E706174680D0A20202020202020';
wwv_flow_api.g_varchar2_table(116) := '2020202020202020207D0D0A2020202020202020202020207D293B0D0A0D0A20202020202020202020202072657175697265285B2276732F656469746F722F656469746F722E6D61696E225D2C2066756E6374696F6E202829207B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(117) := '202020202020202020696E6974456469746F722870436F6E6669672C207374722C2073747244696666293B0D0A20202020202020202020202020202020616464546F6F6C6261722870436F6E6669672C2073747244696666293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(118) := '20202020202020207574696C2E6C6F616465722E73746F702870436F6E6669672E726567696F6E53656C293B0D0A20202020202020202020202020202020242870436F6E6669672E726567696F6E49445265667265736853656C292E7472696767657228';
wwv_flow_api.g_varchar2_table(119) := '2272656E646572656422293B0D0A2020202020202020202020207D293B0D0A20202020202020207D0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(120) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020202A2A0D0A20202020202A2A2066756E6374696F6E20746F2067657420646174612066726F6D20415045580D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(121) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E20676574446174612870436F6E6669672C2070497352';
wwv_flow_api.g_varchar2_table(122) := '65667265736829207B0D0A2020202020202020636F6E7374207375626D69744974656D73203D2070436F6E6669672E6974656D73325375626D69743B0D0A20202020202020207574696C2E6C6F616465722E73746172742870436F6E6669672E72656769';
wwv_flow_api.g_varchar2_table(123) := '6F6E53656C293B0D0A0D0A20202020202020202F2F2063616C6C2061706578207365727665720D0A2020202020202020617065782E7365727665722E706C7567696E280D0A20202020202020202020202070436F6E6669672E616A617849442C207B0D0A';
wwv_flow_api.g_varchar2_table(124) := '202020202020202020202020706167654974656D733A207375626D69744974656D732C0D0A2020202020202020202020207830313A2027474554272C0D0A20202020202020207D2C207B0D0A202020202020202020202020737563636573733A2066756E';
wwv_flow_api.g_varchar2_table(125) := '6374696F6E2028704461746129207B0D0A20202020202020202020202020202020617065782E64656275672E696E666F287B0D0A202020202020202020202020202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E';
wwv_flow_api.g_varchar2_table(126) := '616D65202B2022202D2022202B202267657444617461222C0D0A202020202020202020202020202020202020202022616A6178526573706F6E7365223A2070446174612C0D0A202020202020202020202020202020202020202022666561747572654465';
wwv_flow_api.g_varchar2_table(127) := '7461696C73223A207574696C2E6665617475726544657461696C730D0A202020202020202020202020202020207D293B0D0A202020202020202020202020202020206C6F6164456469746F722870446174612C2070436F6E6669672C2070497352656672';
wwv_flow_api.g_varchar2_table(128) := '657368293B0D0A2020202020202020202020207D2C0D0A2020202020202020202020206572726F723A2066756E6374696F6E2028704461746129207B0D0A20202020202020202020202020202020617065782E64656275672E6572726F72287B0D0A2020';
wwv_flow_api.g_varchar2_table(129) := '20202020202020202020202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E616D65202B2022202D2022202B202267657444617461222C0D0A202020202020202020202020202020202020202022616A6178526573';
wwv_flow_api.g_varchar2_table(130) := '706F6E7365223A2070446174612C0D0A2020202020202020202020202020202020202020226665617475726544657461696C73223A207574696C2E6665617475726544657461696C730D0A202020202020202020202020202020207D293B0D0A20202020';
wwv_flow_api.g_varchar2_table(131) := '2020202020202020202020207574696C2E6C6F616465722E73746F702870436F6E6669672E726567696F6E53656C293B0D0A2020202020202020202020207D2C0D0A20202020202020202020202064617461547970653A20226A736F6E220D0A20202020';
wwv_flow_api.g_varchar2_table(132) := '202020207D293B0D0A202020207D0D0A0D0A2020202072657475726E207B0D0A2020202020202020696E697469616C697A653A2066756E6374696F6E202870526567696F6E49442C2070526567696F6E4944526566726573682C2070416A617849442C20';
wwv_flow_api.g_varchar2_table(133) := '704974656D73325375626D69742C2070506174682C20704865696768742C20704C616E67756167652C20705468656D652C2070427574746F6E732C2070526561644F6E6C7929207B0D0A0D0A202020202020202020202020617065782E64656275672E69';
wwv_flow_api.g_varchar2_table(134) := '6E666F287B0D0A2020202020202020202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E616D65202B2022202D2022202B2022696E697469616C697A65222C0D0A2020202020202020202020202020202022617267';
wwv_flow_api.g_varchar2_table(135) := '756D656E7473223A207B0D0A20202020202020202020202020202020202020202270526567696F6E4944223A2070526567696F6E49442C0D0A20202020202020202020202020202020202020202270526567696F6E494452656672657368223A20705265';
wwv_flow_api.g_varchar2_table(136) := '67696F6E4944526566726573682C0D0A20202020202020202020202020202020202020202270416A61784944223A2070416A617849442C0D0A202020202020202020202020202020202020202022704974656D73325375626D6974223A20704974656D73';
wwv_flow_api.g_varchar2_table(137) := '325375626D69742C0D0A2020202020202020202020202020202020202020227050617468223A2070506174682C0D0A20202020202020202020202020202020202020202270486569676874223A20704865696768742C0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(138) := '202020202020202022704C616E6775616765223A20704C616E67756167652C0D0A202020202020202020202020202020202020202022705468656D65223A20705468656D652C0D0A20202020202020202020202020202020202020202270427574746F6E';
wwv_flow_api.g_varchar2_table(139) := '73223A2070427574746F6E730D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020226665617475726544657461696C73223A207574696C2E6665617475726544657461696C730D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(140) := '207D293B0D0A0D0A2020202020202020202020206C657420636F6E6669674A534F4E203D207B7D3B0D0A202020202020202020202020636F6E6669674A534F4E2E627574746F6E73203D2070427574746F6E732E73706C697428223A22293B0D0A202020';
wwv_flow_api.g_varchar2_table(141) := '202020202020202020636F6E6669674A534F4E2E627574746F6E73537472203D2070427574746F6E733B0D0A202020202020202020202020636F6E6669674A534F4E2E686569676874203D2070486569676874207C7C202235307668223B0D0A20202020';
wwv_flow_api.g_varchar2_table(142) := '2020202020202020636F6E6669674A534F4E2E6C616E6775616765203D20704C616E6775616765207C7C2022706C61696E74657874223B0D0A202020202020202020202020636F6E6669674A534F4E2E7468656D65203D20705468656D65207C7C202276';
wwv_flow_api.g_varchar2_table(143) := '732D6461726B223B0D0A202020202020202020202020636F6E6669674A534F4E2E726567696F6E4944203D2070526567696F6E49443B0D0A202020202020202020202020636F6E6669674A534F4E2E726567696F6E53656C203D20222322202B20705265';
wwv_flow_api.g_varchar2_table(144) := '67696F6E49443B0D0A202020202020202020202020636F6E6669674A534F4E2E726567696F6E494452656672657368203D2070526567696F6E4944526566726573683B0D0A202020202020202020202020636F6E6669674A534F4E2E726567696F6E4944';
wwv_flow_api.g_varchar2_table(145) := '5265667265736853656C203D20222322202B2070526567696F6E4944526566726573683B0D0A202020202020202020202020636F6E6669674A534F4E2E70617468203D2070506174683B0D0A202020202020202020202020636F6E6669674A534F4E2E61';
wwv_flow_api.g_varchar2_table(146) := '6A61784944203D2070416A617849443B0D0A202020202020202020202020636F6E6669674A534F4E2E726561644F6E6C79203D2070526561644F6E6C793B0D0A202020202020202020202020636F6E6669674A534F4E2E6974656D73325375626D697420';
wwv_flow_api.g_varchar2_table(147) := '3D20704974656D73325375626D69743B0D0A0D0A2020202020202020202020202428636F6E6669674A534F4E2E726567696F6E53656C292E68656967687428636F6E6669674A534F4E2E686569676874293B0D0A2020202020202020202020202428636F';
wwv_flow_api.g_varchar2_table(148) := '6E6669674A534F4E2E726567696F6E53656C292E6373732822626F72646572222C202231707820736F6C6964207267626128302C302C302C302E3037352922293B0D0A2020202020202020202020202428636F6E6669674A534F4E2E726567696F6E5365';
wwv_flow_api.g_varchar2_table(149) := '6C292E63737328226F766572666C6F77222C202268696464656E22293B0D0A0D0A2020202020202020202020206765744461746128636F6E6669674A534F4E293B0D0A0D0A202020202020202020202020617065782E726567696F6E2E63726561746528';
wwv_flow_api.g_varchar2_table(150) := '70526567696F6E4944526566726573682C207B0D0A20202020202020202020202020202020747970653A20224D6F6E61636F20565320436F646520456469746F72222C0D0A2020202020202020202020202020202073657456616C75653A2066756E6374';
wwv_flow_api.g_varchar2_table(151) := '696F6E20287056616C75652C20704469666656616C756529207B0D0A202020202020202020202020202020202020202073657456616C7565287056616C75652C20704469666656616C7565293B0D0A202020202020202020202020202020207D2C0D0A20';
wwv_flow_api.g_varchar2_table(152) := '202020202020202020202020202020726566726573683A2066756E6374696F6E202829207B0D0A20202020202020202020202020202020202020206765744461746128636F6E6669674A534F4E2C2074727565293B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(153) := '2020207D2C0D0A20202020202020202020202020202020736176653A2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202073617665436F6E74656E7428636F6E6669674A534F4E293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(154) := '2020202020207D0D0A2020202020202020202020207D293B0D0A20202020202020207D0D0A202020207D0D0A7D3B0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(78945606738350040)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_file_name=>'script.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '636F6E737420617065784D6F6E61636F456469746F723D66756E6374696F6E28652C74297B2275736520737472696374223B636F6E7374206F3D7B6665617475726544657461696C733A7B6E616D653A22415045582D56532D4D6F6E61636F2D45646974';
wwv_flow_api.g_varchar2_table(2) := '6F72222C73637269707456657273696F6E3A2232352E30362E3236222C7574696C56657273696F6E3A2232322E31312E3238222C75726C3A2268747470733A2F2F6769746875622E636F6D2F526F6E6E795765697373222C6C6963656E73653A224D4954';
wwv_flow_api.g_varchar2_table(3) := '2D4C6963656E7365227D2C6973446566696E6564416E644E6F744E756C6C3A66756E6374696F6E2865297B72657475726E206E756C6C213D6526262222213D657D2C6C6F616465723A7B73746172743A66756E6374696F6E286F2C69297B69262674286F';
wwv_flow_api.g_varchar2_table(4) := '292E63737328226D696E2D686569676874222C22313030707822292C652E7574696C2E73686F775370696E6E65722874286F29297D2C73746F703A66756E6374696F6E28652C6F297B6F2626742865292E63737328226D696E2D686569676874222C2222';
wwv_flow_api.g_varchar2_table(5) := '292C7428652B22203E202E752D50726F63657373696E6722292E72656D6F766528292C7428652B22203E202E63742D6C6F6164657222292E72656D6F766528297D7D7D3B6C657420692C6E3D21313B66756E6374696F6E206128692C6E297B6F2E6C6F61';
wwv_flow_api.g_varchar2_table(6) := '6465722E737461727428692E726567696F6E53656C293B636F6E737420613D652E7365727665722E6368756E6B286E292C723D692E6974656D73325375626D69743B652E64656275672E696E666F287B6663743A6F2E6665617475726544657461696C73';
wwv_flow_api.g_varchar2_table(7) := '2E6E616D652B22202D2075706C6F616446696C6573222C6D73673A2255706C6F6164207374617274656421222C7374724172723A612C6665617475726544657461696C733A6F2E6665617475726544657461696C737D292C652E7365727665722E706C75';
wwv_flow_api.g_varchar2_table(8) := '67696E28692E616A617849442C7B7830313A22504F5354222C6630313A612C706167654974656D733A727D2C7B737563636573733A66756E6374696F6E286E297B7428692E726567696F6E49445265667265736853656C292E7472696767657228227570';
wwv_flow_api.g_varchar2_table(9) := '6C6F61642D66696E697368656422292C652E64656275672E696E666F287B6663743A6F2E6665617475726544657461696C732E6E616D652B22202D2075706C6F616446696C6573222C6D73673A2255706C6F61642066696E697368656421222C70446174';
wwv_flow_api.g_varchar2_table(10) := '613A6E2C6665617475726544657461696C733A6F2E6665617475726544657461696C737D292C6F2E6C6F616465722E73746F7028692E726567696F6E53656C297D2C6572726F723A66756E6374696F6E286E2C612C72297B7428692E726567696F6E4944';
wwv_flow_api.g_varchar2_table(11) := '5265667265736853656C292E74726967676572282275706C6F61642D6572726F7222292C652E64656275672E6572726F72287B6663743A6F2E6665617475726544657461696C732E6E616D652B22202D2075706C6F616446696C6573222C6D73673A2255';
wwv_flow_api.g_varchar2_table(12) := '706C6F6164206572726F7221222C6A715848523A6E2C746578745374617475733A612C6572726F725468726F776E3A722C6665617475726544657461696C733A6F2E6665617475726544657461696C737D292C6F2E6C6F616465722E73746F7028692E72';
wwv_flow_api.g_varchar2_table(13) := '6567696F6E53656C297D7D297D66756E6374696F6E207228652C742C6F297B636F6E737420613D646F63756D656E742E676574456C656D656E744279496428652E726567696F6E4944293B6966286E297B636F6E7374206E3D6D6F6E61636F2E65646974';
wwv_flow_api.g_varchar2_table(14) := '6F722E6372656174654D6F64656C28742C652E6C616E6775616765292C723D6D6F6E61636F2E656469746F722E6372656174654D6F64656C286F2C652E6C616E6775616765293B693D6D6F6E61636F2E656469746F722E63726561746544696666456469';
wwv_flow_api.g_varchar2_table(15) := '746F7228612C7B6F726967696E616C4564697461626C653A21652E726561644F6E6C792C726561644F6E6C793A21302C6C616E67756167653A652E6C616E67756167652C7468656D653A652E7468656D652C6175746F6D617469634C61796F75743A2130';
wwv_flow_api.g_varchar2_table(16) := '7D292C692E7365744D6F64656C287B6F726967696E616C3A6E2C6D6F6469666965643A727D297D656C736520693D6D6F6E61636F2E656469746F722E63726561746528612C7B76616C75653A742C6C616E67756167653A652E6C616E67756167652C7468';
wwv_flow_api.g_varchar2_table(17) := '656D653A652E7468656D652C6175746F6D617469634C61796F75743A21302C726561644F6E6C793A652E726561644F6E6C797D297D66756E6374696F6E206C2865297B6C6574206F3D7428223C6469763E3C2F6469763E22293B6F2E616464436C617373';
wwv_flow_api.g_varchar2_table(18) := '2822617065782D76732D6D6F6E61636F2D656469746F722D746F6F6C6261722D636F6E7461696E65722D62746E22292C6F2E616464436C6173732822612D427574746F6E22293B6C657420693D7428223C7370616E3E3C2F7370616E3E22293B72657475';
wwv_flow_api.g_varchar2_table(19) := '726E20692E616464436C6173732822666122292C692E616464436C6173732865292C692E616464436C6173732822617065782D76732D6D6F6E61636F2D656469746F722D746F6F6C6261722D636F6E7461696E65722D62746E2D69636F6E22292C6F2E61';
wwv_flow_api.g_varchar2_table(20) := '7070656E642869292C6F7D66756E6374696F6E20732865297B6C657420743B743D6E3F692E6765744D6F64656C28292E6F726967696E616C2E67657456616C756528293A692E67657456616C756528292C6128652C74297D66756E6374696F6E20642865';
wwv_flow_api.g_varchar2_table(21) := '2C74297B6E3F28692E6765744F726967696E616C456469746F7228292E6765744D6F64656C28292E73657456616C75652865292C6F2E6973446566696E6564416E644E6F744E756C6C2874292626692E6765744D6F646966696564456469746F7228292E';
wwv_flow_api.g_varchar2_table(22) := '6765744D6F64656C28292E73657456616C7565287429293A692E6765744D6F64656C28292E73657456616C75652865297D66756E6374696F6E207528652C752C67297B6C657420662C633B6F2E6973446566696E6564416E644E6F744E756C6C28652926';
wwv_flow_api.g_varchar2_table(23) := '266F2E6973446566696E6564416E644E6F744E756C6C28652E726F77732926266F2E6973446566696E6564416E644E6F744E756C6C28652E726F77735B305D292626286F2E6973446566696E6564416E644E6F744E756C6C28652E726F77735B305D2E56';
wwv_flow_api.g_varchar2_table(24) := '414C55455F4544495429262628663D652E726F77735B305D2E56414C55455F45444954292C6F2E6973446566696E6564416E644E6F744E756C6C28652E726F77735B305D2E56414C55455F44494646293F28633D652E726F77735B305D2E56414C55455F';
wwv_flow_api.g_varchar2_table(25) := '444946462C6E3D2130293A633D662C6F2E6973446566696E6564416E644E6F744E756C6C28652E726F77735B305D2E4C414E475541474529262628752E6C616E67756167653D652E726F77735B305D2E4C414E475541474529292C673F286428662C6329';
wwv_flow_api.g_varchar2_table(26) := '2C6F2E6C6F616465722E73746F7028752E726567696F6E53656C29293A28726571756972652E636F6E666967287B70617468733A7B76733A752E706174687D7D292C72657175697265285B2276732F656469746F722F656469746F722E6D61696E225D2C';
wwv_flow_api.g_varchar2_table(27) := '2866756E6374696F6E28297B7228752C662C63292C66756E6374696F6E28652C6F297B6C657420643D21313B696628652E627574746F6E735374722626652E627574746F6E735374722E6C656E6774683E30297B6C657420733D7428223C6469763E3C2F';
wwv_flow_api.g_varchar2_table(28) := '6469763E22293B696628732E616464436C6173732822617065782D76732D6D6F6E61636F2D656469746F722D746F6F6C6261722D636F6E7461696E657222292C732E6373732822626F726465722D626F74746F6D222C2231707820736F6C696420726762';
wwv_flow_api.g_varchar2_table(29) := '6128302C302C302C302E3037352922292C652E627574746F6E732E696E6465784F662822756E646F22293E2D31297B76617220753D6C282266612D756E646F22293B752E6F6E2822636C69636B222C2866756E6374696F6E28297B6E3F692E6765744F72';
wwv_flow_api.g_varchar2_table(30) := '6967696E616C456469746F7228292E6765744D6F64656C28292E756E646F28293A692E6765744D6F64656C28292E756E646F28297D29292C732E617070656E642875297D696628652E627574746F6E732E696E6465784F6628227265646F22293E2D3129';
wwv_flow_api.g_varchar2_table(31) := '7B6C657420653D6C282266612D72657065617422293B652E6F6E2822636C69636B222C2866756E6374696F6E28297B6E3F692E6765744F726967696E616C456469746F7228292E6765744D6F64656C28292E7265646F28293A692E6765744D6F64656C28';
wwv_flow_api.g_varchar2_table(32) := '292E7265646F28297D29292C732E617070656E642865297D696628652E627574746F6E732E696E6465784F66282273656172636822293E2D31297B6C657420653D6C282266612D73656172636822293B652E6F6E2822636C69636B222C2866756E637469';
wwv_flow_api.g_varchar2_table(33) := '6F6E28297B643D21642C643F6E3F28692E6765744F726967696E616C456469746F7228292E676574416374696F6E2822616374696F6E732E66696E6422292E72756E28292C692E6765744D6F646966696564456469746F7228292E676574416374696F6E';
wwv_flow_api.g_varchar2_table(34) := '2822616374696F6E732E66696E6422292E72756E2829293A692E676574416374696F6E2822616374696F6E732E66696E6422292E72756E28293A6E3F28692E6765744F726967696E616C456469746F7228292E7472696767657228226B6579626F617264';
wwv_flow_api.g_varchar2_table(35) := '222C22636C6F736546696E6457696467657422292C692E6765744D6F646966696564456469746F7228292E7472696767657228226B6579626F617264222C22636C6F736546696E645769646765742229293A692E7472696767657228226B6579626F6172';
wwv_flow_api.g_varchar2_table(36) := '64222C22636C6F736546696E6457696467657422297D29292C732E617070656E642865297D696628652E627574746F6E732E696E6465784F6628226469666622293E2D31297B6C657420743D6C282266612D6172726F77732D6822293B742E6F6E282263';
wwv_flow_api.g_varchar2_table(37) := '6C69636B222C2866756E6374696F6E28297B6C657420743B643D21312C6E3D216E2C743D6E3F692E67657456616C756528293A692E6765744D6F64656C28292E6F726967696E616C2E67657456616C756528292C692E646973706F736528292C7228652C';
wwv_flow_api.g_varchar2_table(38) := '742C6F297D29292C732E617070656E642874297D696628652E627574746F6E732E696E6465784F6628227361766522293E2D31297B6C657420743D6C282266612D7361766522293B742E6F6E2822636C69636B222C2866756E6374696F6E28297B6C6574';
wwv_flow_api.g_varchar2_table(39) := '20743B743D6E3F692E6765744D6F64656C28292E6F726967696E616C2E67657456616C756528293A692E67657456616C756528292C6128652C74297D29292C732E617070656E642874297D7428652E726567696F6E53656C292E70726570656E64287329';
wwv_flow_api.g_varchar2_table(40) := '7D7428652E726567696F6E49445265667265736853656C292E6F6E282273617665222C2866756E6374696F6E28297B732865297D29297D28752C63292C6F2E6C6F616465722E73746F7028752E726567696F6E53656C292C7428752E726567696F6E4944';
wwv_flow_api.g_varchar2_table(41) := '5265667265736853656C292E74726967676572282272656E646572656422297D2929297D66756E6374696F6E206728742C69297B636F6E7374206E3D742E6974656D73325375626D69743B6F2E6C6F616465722E737461727428742E726567696F6E5365';
wwv_flow_api.g_varchar2_table(42) := '6C292C652E7365727665722E706C7567696E28742E616A617849442C7B706167654974656D733A6E2C7830313A22474554227D2C7B737563636573733A66756E6374696F6E286E297B652E64656275672E696E666F287B6663743A6F2E66656174757265';
wwv_flow_api.g_varchar2_table(43) := '44657461696C732E6E616D652B22202D2067657444617461222C616A6178526573706F6E73653A6E2C6665617475726544657461696C733A6F2E6665617475726544657461696C737D292C75286E2C742C69297D2C6572726F723A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(44) := '69297B652E64656275672E6572726F72287B6663743A6F2E6665617475726544657461696C732E6E616D652B22202D2067657444617461222C616A6178526573706F6E73653A692C6665617475726544657461696C733A6F2E6665617475726544657461';
wwv_flow_api.g_varchar2_table(45) := '696C737D292C6F2E6C6F616465722E73746F7028742E726567696F6E53656C297D2C64617461547970653A226A736F6E227D297D72657475726E7B696E697469616C697A653A66756E6374696F6E28692C6E2C612C722C6C2C752C662C632C702C44297B';
wwv_flow_api.g_varchar2_table(46) := '652E64656275672E696E666F287B6663743A6F2E6665617475726544657461696C732E6E616D652B22202D20696E697469616C697A65222C617267756D656E74733A7B70526567696F6E49443A692C70526567696F6E4944526566726573683A6E2C7041';
wwv_flow_api.g_varchar2_table(47) := '6A617849443A612C704974656D73325375626D69743A722C70506174683A6C2C704865696768743A752C704C616E67756167653A662C705468656D653A632C70427574746F6E733A707D2C6665617475726544657461696C733A6F2E6665617475726544';
wwv_flow_api.g_varchar2_table(48) := '657461696C737D293B6C6574206D3D7B7D3B6D2E627574746F6E733D702E73706C697428223A22292C6D2E627574746F6E735374723D702C6D2E6865696768743D757C7C2235307668222C6D2E6C616E67756167653D667C7C22706C61696E7465787422';
wwv_flow_api.g_varchar2_table(49) := '2C6D2E7468656D653D637C7C2276732D6461726B222C6D2E726567696F6E49443D692C6D2E726567696F6E53656C3D2223222B692C6D2E726567696F6E4944526566726573683D6E2C6D2E726567696F6E49445265667265736853656C3D2223222B6E2C';
wwv_flow_api.g_varchar2_table(50) := '6D2E706174683D6C2C6D2E616A617849443D612C6D2E726561644F6E6C793D442C6D2E6974656D73325375626D69743D722C74286D2E726567696F6E53656C292E686569676874286D2E686569676874292C74286D2E726567696F6E53656C292E637373';
wwv_flow_api.g_varchar2_table(51) := '2822626F72646572222C2231707820736F6C6964207267626128302C302C302C302E3037352922292C74286D2E726567696F6E53656C292E63737328226F766572666C6F77222C2268696464656E22292C67286D292C652E726567696F6E2E6372656174';
wwv_flow_api.g_varchar2_table(52) := '65286E2C7B747970653A224D6F6E61636F20565320436F646520456469746F72222C73657456616C75653A66756E6374696F6E28652C74297B6428652C74297D2C726566726573683A66756E6374696F6E28297B67286D2C2130297D2C736176653A6675';
wwv_flow_api.g_varchar2_table(53) := '6E6374696F6E28297B73286D297D7D297D7D7D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(83103131278015277)
,p_plugin_id=>wwv_flow_api.id(30127016042927264490)
,p_file_name=>'script.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
