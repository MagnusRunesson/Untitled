using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEngine;

namespace Assets.Editor
{
    public class FileIdConstants
    {
        private List<string> m_allFiles;
        private string m_asmFileList;

        public FileIdConstants()
        {
            m_allFiles = new List<string>();
            m_asmFileList = "FileIDList:\n";
        }

        public void AddFile(string _filename)
        {
            string constant = GetConstantNameFromFileName(_filename);

            // Append to files.asm
            m_asmFileList += constant.PadRight(40) + "equ " + m_allFiles.Count + "\n";

            //
            m_allFiles.Add(constant);
        }

        private string GetConstantNameFromFileName(string _sourceFileName)
        {
            string ret = "fileid_";
            ret += System.IO.Path.GetFileNameWithoutExtension(_sourceFileName);
            ret = ret.Replace(' ', '_');
            ret = ret.ToLower();

            return ret;
        }

        public void ExportAsm(string fullFilePath)
        {
            File.WriteAllText(fullFilePath, m_asmFileList);
        }

        public int GetIDFromConstant(string _constant)
        {
            int i;
            for (i = 0; i < m_allFiles.Count; i++)
            {
                if (m_allFiles[i].Equals(_constant))
                    return i;
            }

            Debug.LogException(new UnityException("The constant '" + _constant + "' isn't known to the project."));
            return -1;
        }
    }
}
