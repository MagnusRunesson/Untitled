using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;

namespace Assets.Editor
{

    public class FileData
    {
        string []m_asmData;
        string m_asmFileMap;

        public FileData()
        {
            m_asmData = new string[]
            {
                "",
                "StaticData:\n"
            };
            m_asmFileMap = "FileIDMap:\n";
        }

        public void AddDynamicFile(string _filename)
        {
            AddFile(_filename, false);
        }

        public void AddStaticFile(string _filename)
        {
            AddFile(_filename, true);
        }

        //public void AddFile(string _filename, string _alternativeAmigaFilename = null)
        
        private void AddFile(string _filename, bool isStatic)
        {
            int dataIndex = isStatic ? 1 : 0;
            string chunkSize = isStatic ? "4" : "_chunk_size";

            string label = GetLabelNameFromFileName(_filename);


            // Append to data.asm
            m_asmData[dataIndex] += "\n\n; " + _filename + "\n\n";
            m_asmData[dataIndex] += "\tcnop\t\t0," + chunkSize + "\n";
            m_asmData[dataIndex] += label + ":\n";

            m_asmData[dataIndex] += "\tincbin\t\"../src/incbin/" + _filename + "\"\n";

            if (isStatic)
            {
                m_asmData[dataIndex] += (label + "_pos").PadRight(60) + "equ (" + label + "-StaticData)\n";
            }
            else
            {
                m_asmData[dataIndex] += (label + "_pos").PadRight(60) + "equ " + label + "/" + chunkSize + "\n";
                m_asmData[dataIndex] += (label + "_length").PadRight(60) + "equ ((" + label + "_end-" + label + ")+(_chunk_size-1))/_chunk_size\n";
                m_asmData[dataIndex] += label + "_end:\n";
            }


            // Append to filemap.asm      
            if (isStatic)
            {
                m_asmFileMap += "\tdc.l\t$80000000|" + label + "_pos\n";
            }
            else
            {
                m_asmFileMap += "\tdc.w\t" + label + "_pos," + label + "_length\n";
            }
        }

        private string GetLabelNameFromFileName(string _sourceFileName)
        {
            string ret = "_data_";
            ret += System.IO.Path.GetFileNameWithoutExtension(_sourceFileName);
            ret = ret.Replace(' ', '_');
            ret = ret.ToLower();

            return ret;
        }

        public void ExportDynamicDataFile(string _fullFilePath)
        {
            File.WriteAllText(_fullFilePath, m_asmData[0]);
        }

        public void ExportStaticDataFile(string _fullFilePath)
        {
            File.WriteAllText(_fullFilePath, m_asmData[1]);
        }

        public void ExportFileIdMap(string _fullFilePath)
        {
            File.WriteAllText(_fullFilePath, m_asmFileMap);
        }
    }
}
