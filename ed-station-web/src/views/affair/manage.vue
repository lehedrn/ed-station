<template>
  <basic-container>
    <avue-crud
      :option="option"
      :table-loading="loading"
      :data="data"
      v-model:page="page"
      :permission="permissionList"
      :before-open="beforeOpen"
      v-model="form"
      ref="crud"
      @row-update="rowUpdate"
      @row-save="rowSave"
      @row-del="rowDel"
      @search-change="searchChange"
      @search-reset="searchReset"
      @selection-change="selectionChange"
      @current-change="currentChange"
      @size-change="sizeChange"
      @refresh-change="refreshChange"
      @on-load="onLoad"
    >
      <template #menu-left>
        <el-button
          type="danger"
          icon="el-icon-delete"
          plain
          v-if="permission['affair_manage_delete']"
          @click="handleBatchDelete"
        >批量删除</el-button>
        <el-button
          type="warning"
          icon="el-icon-download"
          plain
          v-if="permission['affair_manage_publish']"
          @click="handleBatchPublish"
        >批量发布</el-button>
        <el-button
          type="info"
          icon="el-icon-upload2"
          plain
          v-if="permission['affair_manage_unpublish']"
          @click="handleBatchUnpublish"
        >批量下架</el-button>
      </template>
      <template #status="{ row }">
        <el-tag :type="row.status === 1 ? 'success' : 'info'">
          {{ row.statusDict || (row.status === 1 ? '正常' : '下架') }}
        </el-tag>
      </template>
      <template #materials-form="scope">
        <div class="materials-section">
          <el-divider>所需材料</el-divider>
          <div class="materials-toolbar">
            <el-button type="primary" icon="el-icon-plus" @click="handleAddMaterial">添加材料</el-button>
          </div>
          <el-table :data="materialList" border style="margin-top: 10px">
            <el-table-column prop="materialName" label="材料名称" width="200" />
            <el-table-column prop="materialType" label="材料类型" width="120">
              <template #default="{ row }">
                {{ getMaterialTypeLabel(row.materialType) }}
              </template>
            </el-table-column>
            <el-table-column prop="materialCopies" label="份数" width="80" />
            <el-table-column prop="materialRemark" label="材料说明" show-overflow-tooltip />
            <el-table-column label="附件" width="150">
              <template #default="{ row }">
                <el-tag
                  v-if="row.attach && (row.attach.originalName || row.attach.fileName)"
                  size="small"
                  style="cursor: pointer"
                  @click="handleDownloadAttach(row.attach)"
                >
                  <el-icon><Document /></el-icon>
                  {{ row.attach.originalName || row.attach.fileName }}
                </el-tag>
                <span v-else style="color: #999">无附件</span>
              </template>
            </el-table-column>
            <el-table-column label="操作" width="150" fixed="right">
              <template #default="{ row, $index }">
                <el-button
                  type="primary"
                  text
                  icon="el-icon-edit"
                  @click="handleEditMaterial(row, $index)"
                >编辑</el-button>
                <el-button
                  type="danger"
                  text
                  icon="el-icon-delete"
                  @click="handleDeleteMaterial($index)"
                >删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </template>
      <template #menu="scope">
        <el-button
          type="success"
          text
          icon="el-icon-circle-check"
          v-if="permission['affair_manage_publish'] && scope.row.status === 2"
          @click.stop="handlePublish(scope.row)"
        >发布</el-button>
        <el-button
          type="warning"
          text
          icon="el-icon-circle-close"
          v-if="permission['affair_manage_unpublish'] && scope.row.status === 1"
          @click.stop="handleUnpublish(scope.row)"
        >下架</el-button>
      </template>
    </avue-crud>

    <!-- 材料编辑弹窗 -->
    <MaterialDialog
      v-model="materialDialogVisible"
      :title="materialDialogTitle"
      :material-data="currentMaterial"
      @submit="handleMaterialSubmit"
    />
  </basic-container>
</template>

<script>
import { getList, getDetail, save, update, remove, publish, unpublish } from '@/api/affair/manage';
import { mapGetters } from 'vuex';
import MaterialDialog from './MaterialDialog.vue';

export default {
  name: 'AffairManage',
  components: {
    MaterialDialog,
  },
  data() {
    return {
      form: {},
      query: {},
      loading: true,
      page: {
        pageSize: 10,
        currentPage: 1,
        total: 0,
      },
      selectionList: [],
      materialList: [],
      materialDialogVisible: false,
      materialDialogTitle: '添加材料',
      currentMaterial: {},
      editingMaterialIndex: -1,
      materialTypeDict: {},
      option: {
        height: 'auto',
        calcHeight: 32,
        tip: false,
        searchShow: true,
        searchMenuSpan: 6,
        border: true,
        index: true,
        viewBtn: true,
        selection: true,
        dialogWidth: 1000,
        dialogClickModal: false,
        customForm: true,
        grid: false,
        column: [
          {
            label: '事项名称',
            prop: 'affairName',
            search: true,
            searchSpan: 4,
            span: 24,
            rules: [
              {
                required: true,
                message: '请输入事项名称',
                trigger: 'blur',
              },
            ],
            placeholder: '请输入事项名称，最多 200 字',
          },
          {
            label: '事项简称',
            prop: 'affairShortName',
            search: true,
            searchSpan: 4,
            span: 12,
            placeholder: '请输入事项简称，最多 100 字',
          },
          {
            label: '事项类别',
            prop: 'affairType',
            type: 'select',
            search: true,
            searchSpan: 4,
            span: 12,
            dicUrl: '/blade-system/dict/dictionary?code=affair_type',
            props: {
              label: 'dictValue',
              value: 'dictKey',
            },
            dataType: 'string',
            rules: [
              {
                required: true,
                message: '请选择事项类别',
                trigger: 'change',
              },
            ],
          },
          {
            label: '法定时限',
            prop: 'legalLimit',
            type: 'number',
            span: 12,
            gridRow: true,
            min: 0,
            placeholder: '请输入法定时限（工作日）',
            rules: [
              {
                required: true,
                message: '请输入法定时限',
                trigger: 'blur',
              },
            ],
          },
          {
            label: '承诺时限',
            prop: 'promiseLimit',
            type: 'number',
            span: 12,
            gridRow: true,
            min: 0,
            placeholder: '请输入承诺时限（工作日）',
            rules: [
              {
                required: true,
                message: '请输入承诺时限',
                trigger: 'blur',
              },
              {
                validator: (rule, value, callback, source, options) => {
                  const legalLimit = options?.formData?.legalLimit;
                  if (value && legalLimit && value > legalLimit) {
                    callback(new Error('承诺时限不能大于法定时限'));
                  } else {
                    callback();
                  }
                },
                trigger: 'blur',
              },
            ],
          },
          {
            label: '办理条件',
            prop: 'handleCondition',
            type: 'ueditor',
            span: 24,
            hide: true,
            gridRow: true,
            minRows: 10,
            rules: [
              {
                required: true,
                message: '请输入办理条件',
                trigger: 'blur',
              },
            ],
          },
          {
            label: '备注说明',
            prop: 'remark',
            type: 'textarea',
            span: 24,
            hide: true,
            gridRow: true,
            minRows: 3,
            maxlength: 500,
            showWordLimit: true,
          },
          {
            label: '事项状态',
            prop: 'status',
            type: 'select',
            search: true,
            searchSpan: 4,
            span: 12,
            dicUrl: '/blade-system/dict/dictionary?code=affair_status',
            props: {
              label: 'dictValue',
              value: 'dictKey',
            },
            dataType: 'number',
            slot: true,
            editDisplay: false,
            addDisplay: false,
          },
          {
            label: '发布时间',
            prop: 'publishTime',
            type: 'datetime',
            span: 12,
            format: 'YYYY-MM-DD HH:mm:ss',
            valueFormat: 'YYYY-MM-DD HH:mm:ss',
            readonly: true,
            editDisplay: false,
            addDisplay: false,
            viewDisplay: true,
          },
          {
            label: '创建时间',
            prop: 'createTime',
            type: 'datetime',
            span: 12,
            format: 'YYYY-MM-DD HH:mm:ss',
            valueFormat: 'YYYY-MM-DD HH:mm:ss',
            readonly: true,
            hide: true,
            addDisplay: false,
            editDisplay: false,
          },
          {
            label: '所需材料',
            prop: 'materials',
            span: 24,
            row: true,
            hide: true,
            viewDisplay: true,
            addDisplay: true,
            editDisplay: true,
          },
        ],
      },
      data: [],
    };
  },
  computed: {
    ...mapGetters(['permission']),
    permissionList() {
      return {
        addBtn: this.validData(this.permission['affair_manage_add'], false),
        viewBtn: this.validData(this.permission['affair_manage_view'], false),
        delBtn: this.validData(this.permission['affair_manage_delete'], false),
        editBtn: this.validData(this.permission['affair_manage_edit'], false),
      };
    },
    ids() {
      let ids = [];
      this.selectionList.forEach((ele) => {
        ids.push(ele.id);
      });
      return ids.join(',');
    },
  },
  methods: {
    // 材料类型字典辅助方法
    getMaterialTypeLabel(type) {
      return this.materialTypeDict[type] || type;
    },
    loadMaterialTypeDict() {
      this.$axios
        .get('/blade-system/dict/dictionary', {
          params: { code: 'material_type' },
        })
        .then((res) => {
          if (res.data && res.data.data) {
            const dict = {};
            res.data.data.forEach((item) => {
              dict[item.dictKey] = item.dictValue;
            });
            this.materialTypeDict = dict;
          }
        })
        .catch(() => {
          // 使用默认字典
          this.materialTypeDict = {
            '01': '原件',
            '02': '复印件',
            '03': '电子版',
            '04': '其他',
          };
        });
    },
    // 材料管理方法
    handleAddMaterial() {
      this.materialDialogTitle = '添加材料';
      this.currentMaterial = {};
      this.editingMaterialIndex = -1;
      this.materialDialogVisible = true;
    },
    handleEditMaterial(row, index) {
      this.materialDialogTitle = '编辑材料';
      this.currentMaterial = JSON.parse(JSON.stringify(row));
      this.editingMaterialIndex = index;
      this.materialDialogVisible = true;
    },
    handleDeleteMaterial(index) {
      this.$confirm('确定删除该材料？', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          this.materialList.splice(index, 1);
          this.$message.success('删除成功');
        })
        .catch(() => {});
    },
    // 下载附件
    handleDownloadAttach(attach) {
      if (attach && attach.filePath) {
        window.open(attach.filePath, '_blank');
      } else if (attach && attach.link) {
        window.open(attach.link, '_blank');
      }
    },
    handleMaterialSubmit(materialData) {
      if (this.editingMaterialIndex >= 0) {
        // 编辑模式
        this.$set(this.materialList, this.editingMaterialIndex, materialData);
      } else {
        // 新增模式
        this.materialList.push(materialData);
      }
      this.materialDialogVisible = false;
    },
    // 保存和更新方法（需要包含材料列表）
    rowSave(row, done, loading) {
      // 将材料列表添加到表单数据中
      row.materials = this.materialList;
      save(row).then(
        () => {
          this.onLoad(this.page);
          this.$message({
            type: 'success',
            message: '操作成功!',
          });
          done();
        },
        (error) => {
          window.console.log(error);
          loading();
        }
      );
    },
    rowUpdate(row, index, done, loading) {
      // 将材料列表添加到表单数据中
      row.materials = this.materialList;
      update(row).then(
        () => {
          this.onLoad(this.page);
          this.$message({
            type: 'success',
            message: '操作成功!',
          });
          done();
        },
        (error) => {
          window.console.log(error);
          loading();
        }
      );
    },
    rowDel(row) {
      this.$confirm('确定将选择数据删除？', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          return remove(row.id);
        })
        .then(() => {
          this.onLoad(this.page);
          this.$message({
            type: 'success',
            message: '操作成功!',
          });
        });
    },
    handleBatchDelete() {
      if (this.selectionList.length === 0) {
        this.$message.warning('请选择至少一条数据');
        return;
      }
      this.$confirm('确定将选择数据删除？', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          return remove(this.ids);
        })
        .then(() => {
          this.onLoad(this.page);
          this.$message({
            type: 'success',
            message: '操作成功!',
          });
          this.$refs.crud.toggleSelection();
        });
    },
    handlePublish(row) {
      this.$confirm('确定发布该事项？发布后将对外展示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          return publish(row.id);
        })
        .then(() => {
          this.onLoad(this.page);
          this.$message({
            type: 'success',
            message: '发布成功!',
          });
        });
    },
    handleUnpublish(row) {
      this.$confirm('确定下架该事项？下架后将不再对外展示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      })
        .then(() => {
          return unpublish(row.id);
        })
        .then(() => {
          this.onLoad(this.page);
          this.$message({
            type: 'success',
            message: '下架成功!',
          });
        });
    },
    handleBatchPublish() {
      if (this.selectionList.length === 0) {
        this.$message.warning('请选择至少一条数据');
        return;
      }
      this.$confirm('确定发布选中的事项？', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }).then(() => {
        const publishPromises = this.selectionList.map((item) => publish(item.id));
        Promise.all(publishPromises)
          .then(() => {
            this.onLoad(this.page);
            this.$message({
              type: 'success',
              message: '批量发布成功!',
            });
            this.$refs.crud.toggleSelection();
          })
          .catch((error) => {
            window.console.log(error);
            this.$message.error('批量发布失败');
          });
      });
    },
    handleBatchUnpublish() {
      if (this.selectionList.length === 0) {
        this.$message.warning('请选择至少一条数据');
        return;
      }
      this.$confirm('确定下架选中的事项？', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }).then(() => {
        const unpublishPromises = this.selectionList.map((item) => unpublish(item.id));
        Promise.all(unpublishPromises)
          .then(() => {
            this.onLoad(this.page);
            this.$message({
              type: 'success',
              message: '批量下架成功!',
            });
            this.$refs.crud.toggleSelection();
          })
          .catch((error) => {
            window.console.log(error);
            this.$message.error('批量下架失败');
          });
      });
    },
    beforeOpen(done, type) {
      if (['edit', 'view'].includes(type)) {
        getDetail(this.form.id).then((res) => {
          this.form = res.data.data;
          // 加载材料列表
          if (this.form.materials && Array.isArray(this.form.materials)) {
            // 确保每个材料的 attach 对象有正确的字段
            this.materialList = this.form.materials.map((material) => {
              if (material.attach) {
                // 确保 filePath 存在
                if (!material.attach.filePath && material.attach.link) {
                  material.attach.filePath = material.attach.link;
                }
                // 确保 fileName 存在
                if (!material.attach.fileName && material.attach.originalName) {
                  material.attach.fileName = material.attach.originalName;
                }
              }
              return material;
            });
          } else {
            this.materialList = [];
          }
        });
      } else if (type === 'add') {
        // 新增模式，清空材料列表
        this.materialList = [];
      }
      // 加载材料类型字典
      this.loadMaterialTypeDict();
      done();
    },
    beforeClose(done) {
      this.materialList = [];
      done();
    },
    searchReset() {
      this.query = {};
      this.onLoad(this.page);
    },
    searchChange(params, done) {
      this.query = params;
      this.page.currentPage = 1;
      this.onLoad(this.page, params);
      done();
    },
    selectionChange(list) {
      this.selectionList = list;
    },
    selectionClear() {
      this.selectionList = [];
      this.$refs.crud.toggleSelection();
    },
    currentChange(currentPage) {
      this.page.currentPage = currentPage;
    },
    sizeChange(pageSize) {
      this.page.pageSize = pageSize;
    },
    refreshChange() {
      this.onLoad(this.page, this.query);
    },
    onLoad(page, params = {}) {
      this.loading = true;
      getList(page.currentPage, page.pageSize, Object.assign(params, this.query))
        .then((res) => {
          const data = res.data.data;
          this.page.total = data.total;
          this.data = data.records;
          this.loading = false;
          this.selectionClear();
        })
        .catch(() => {
          this.loading = false;
          this.$message.error('加载数据失败');
        });
    },
  },
};
</script>

<style scoped>
.materials-section {
  margin-top: 20px;
  padding: 16px;
  background-color: #f5f7fa;
  border-radius: 4px;
}

.materials-toolbar {
  margin: 10px 0;
}

.materials-section .el-divider {
  margin: 0 0 16px 0;
}
</style>
